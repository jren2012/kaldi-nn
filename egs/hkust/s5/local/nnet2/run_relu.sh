#!/bin/bash


# This runs on the full training set (with duplicates removed), with p-norm
# units, on top of fMLLR features, on GPU.

temp_dir=
dir=exp/nnet2_relu
stage=323

. ./cmd.sh
. ./path.sh

. utils/parse_options.sh

parallel_opts="--gpu 1"  # This is suitable for the CLSP network, you'll
                          # likely have to change it.

( 
  if [ ! -f $dir/final.mdl ]; then
    steps/nnet2/train_relu_accel2.sh --parallel-opts "$parallel_opts" \
      --cmd "$decode_cmd" --stage $stage \
      --num-threads 1 --minibatch-size 512 \
      --mix-up 20000 --samples-per-iter 300000 \
      --num-epochs 15 \
      --initial-effective-lrate 0.001 --final-effective-lrate 0.00005 \
      --num-jobs-initial 3 --num-jobs-final 8 --num-hidden-layers 4 --splice-width 5 \
      --hidden-dim 2000 \
      data/train data/lang exp/tri5a_ali $dir || exit 1;
  fi

  steps/nnet2/decode.sh --cmd "$decode_cmd" --nj 10 \
    --config conf/decode.config \
    --transform-dir exp/tri5a/decode \
    exp/tri5a/graph data/dev \
    $dir/decode || exit 1;
)
