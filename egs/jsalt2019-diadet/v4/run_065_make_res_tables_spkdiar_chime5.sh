#!/bin/bash
# Copyright      2018   Johns Hopkins University (Author: Jesus Villalba)
#
# Apache 2.0.
#
. ./cmd.sh
. ./path.sh
set -e

config_file=default_config.sh

. parse_options.sh || exit 1;
. $config_file

score_dir=exp/diarization/$nnet_name/${be_diar_name}
name="$nnet_name $be_diar_name"

score_adapt_dir=exp/diarization/$nnet_name/${be_diar_chime5_name}
name_adapt="$nnet_name $be_diar_chime5_name"

score_adapt_enh_dir=exp/diarization/$nnet_name/${be_diar_chime5_enhanced_name}
name_adapt_enh="$nnet_name $be_diar_chime5_enhanced_name"

#energy VAD
local/make_table_line_spkdiar_jsalt19_chime5.sh --print-header true "$name lstm-vad" $score_dir
local/make_table_line_spkdiar_jsalt19_chime5.sh "$name_adapt lstm-vad" $score_adapt_dir
local/make_table_line_spkdiar_jsalt19_chime5.sh "$name_adapt lstm-vad + reseg" ${score_adapt_dir}_VB

#echo ""

#energy VAD of enhanced
local/make_table_line_spkdiar_jsalt19_chime5_enhanced.sh "$name lstm-vad speech-enhanced" $score_dir
local/make_table_line_spkdiar_jsalt19_chime5_enhanced.sh "$name_adapt_enh lstm-vad speech-enhanced" $score_adapt_enh_dir
local/make_table_line_spkdiar_jsalt19_chime5_enhanced.sh "$name_adapt_enh lstm-vad speech-enhanced + reseg" ${score_adapt_enh_dir}_VB

echo ""

#GT VAD
local/make_table_line_spkdiar_jsalt19_chime5.sh --print-header true --use-gtvad true "$name" $score_dir
local/make_table_line_spkdiar_jsalt19_chime5.sh --use-gtvad true "$name_adapt" $score_adapt_dir
local/make_table_line_spkdiar_jsalt19_chime5.sh --use-gtvad true "$name_adapt + reseg" ${score_adapt_dir}_VB


#echo ""

#GT VAD
local/make_table_line_spkdiar_jsalt19_chime5_enhanced.sh --use-gtvad true "$name speech-enhanced" $score_dir
local/make_table_line_spkdiar_jsalt19_chime5_enhanced.sh --use-gtvad true "$name_adapt_enh speech-enhanced" $score_adapt_enh_dir
local/make_table_line_spkdiar_jsalt19_chime5_enhanced.sh --use-gtvad true "$name_adapt_enh speech-enhanced + reseg" ${score_adapt_enh_dir}_VB
exit
