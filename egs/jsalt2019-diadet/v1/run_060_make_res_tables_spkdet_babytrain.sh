#!/bin/bash
# Copyright      2018   Johns Hopkins University (Author: Jesus Villalba)
#
# Apache 2.0.
#
. ./cmd.sh
. ./path.sh
set -e

config_file=default_config.sh
stage=1

. parse_options.sh || exit 1;
. $config_file

score_dir0=exp/scores/$nnet_name/${be_name}
name0="$nnet_name $be_name"



if [ $stage -le 1 ]; then
#energy VAD
conds=(plda plda_spkdetdiar_nnet${nnet_name}_thrbest)
conds_name=("no-adapt e-vad no-diar" "no-adapt e-vad auto-diar")


echo "Energy VAD"
args="--print-header true"
for((i=0;i<${#conds[*]};i++))
do
    score_dir=$score_dir0/${conds[$i]}_cal_v1
    name="$name0 ${conds_name[$i]}"
    local/make_table_line_spkdet_jsalt19_xxx.sh $args "$name" babytrain $score_dir
    args=""
done
echo ""
fi

#####

if [ $stage -le 2 ]; then
#GT VAD
conds=(plda_gtvad plda_spkdetdiar_nnet${nnet_name}_thrbest_gtvad)
conds_name=("no-adapt gt-vad no-diar" "no-adapt gt-vad auto-diar")


echo "Ground Truth VAD"
args="--print-header true"
for((i=0;i<${#conds[*]};i++))
do
    score_dir=$score_dir0/${conds[$i]}_cal_v1
    name="$name0 ${conds_name[$i]}"
    local/make_table_line_spkdet_jsalt19_xxx.sh $args "$name" babytrain $score_dir
    args=""
done
echo ""

fi
#####

if [ $stage -le 3 ]; then
#GT diarization
conds=(plda_gtdiar)
conds_name=("no-adapt gt-diar")


echo "Ground Truth diarization"
args="--print-header true"
#print EER table
for((i=0;i<${#conds[*]};i++))
do
    score_dir=$score_dir0/${conds[$i]}_cal_v1
    name="$name0 ${conds_name[$i]}"
    local/make_table_line_spkdet_jsalt19_xxx.sh $args "$name" babytrain $score_dir
    args=""
done
echo ""
fi
#####

