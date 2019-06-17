#!/bin/bash
# Copyright       2019   Johns Hopkins University (Author: Jesus Villalba)
#                
# Apache 2.0.
#
. ./cmd.sh
. ./path.sh
set -e

stage=1
config_file=default_config.sh

. parse_options.sh || exit 1;
. $config_file

. datapath.sh 

xvector_dir=exp/xvectors/$nnet_name
be_babytrain_dir=exp/be/$nnet_name/$be_babytrain_name
be_chime5_dir=exp/be/$nnet_name/$be_chime5_name
be_ami_dir=exp/be/$nnet_name/$be_ami_name

score_dir=exp/scores/$nnet_name/${be_name}
score_plda_dir=$score_dir/plda_${spkdet_diar_name}
score_plda_adapt_dir=$score_dir/plda_adapt_${spkdet_diar_name}
score_plda_adapt_snorm_dir=$score_dir/plda_adapt_snorm_${spkdet_diar_name}

name_vec=(babytrain ami)
be_vec=($be_babytrain_dir,$be_ami_dir)
coh_vec=(jsalt19_spkdet_babytrain_train jsalt19_spkdet_ami_train)
num_dbs=${#name_vec[@]}

#train_cmd=run.pl

if [ $stage -le 1 ];then

    for((i=0;i<$num_dbs;i++))
    do
	echo "Eval ${name_vec[$i]} wo diarization"
	for part in dev eval
	do
	    db=jsalt19_spkdet_${name_vec[$i]}_${part}
	    coh_data=${coh_vec[$i]}
	    be_dir=${be_vec[$i]}
	    scorer=local/score_${name_vec[$i]}_spkdet.sh

	    for dur in 5 15 30
	    do
		# ground truth diar
		(
		    steps_be/eval_be_diar_v1.sh --cmd "$train_cmd" --plda_type $plda_type \
					   data/${db}_test/trials/trials_enr$dur \
					   data/${db}_enr${dur}/utt2model \
					   $xvector_dir/${db}_enr${dur}_test_${spkdet_diar_name}/xvector.scp \
					   data/${db}_test_${spkdet_diar_name}/utt2orig \
					   $be_dir/lda_lnorm.h5 \
					   $be_dir/plda.h5 \
					   $score_plda_dir/${db}_enr${dur}_scores
		    
		    $scorer data/${db}_test/trials $part $dur $score_plda_dir 
		) #&


		# ground truth diar + PLDA adapt
		(
		    steps_be/eval_be_diar_v1.sh --cmd "$train_cmd" --plda_type $plda_type \
					   data/${db}_test/trials/trials_enr$dur \
					   data/${db}_enr${dur}/utt2model \
					   $xvector_dir/${db}_enr${dur}_test_${spkdet_diar_name}/xvector.scp \
					   data/${db}_test_${spkdet_diar_name}/utt2orig \
					   $be_dir/lda_lnorm_adapt.h5 \
					   $be_dir/plda_adapt.h5 \
					   $score_plda_adapt_dir/${db}_enr${dur}_scores
		    
		    $scorer data/${db}_test/trials $part $dur $score_plda_adapt_dir 
		) #&

		# ground truth diar + PLDA adapt + AS-Norm
		(
		    steps_be/eval_be_diar_snorm_v1.sh --cmd "$train_cmd" --plda_type $plda_type \
						 data/${db}_test/trials/trials_enr$dur \
						 data/${db}_enr${dur}/utt2model \
						 $xvector_dir/${db}_enr${dur}_test_${spkdet_diar_name}/xvector.scp \
						 data/${db}_test_${spkdet_diar_name}/utt2orig \
						 data/${coh_data}/utt2spk \
						 $xvector_dir/${coh_data}/xvector.scp \
						 $be_dir/lda_lnorm_adapt.h5 \
						 $be_dir/plda_adapt.h5 \
						 $score_plda_adapt_snorm_dir/${db}_enr${dur}_scores
		    
		    $scorer data/${db}_test/trials $part $dur $score_plda_adapt_snorm_dir 
		) #&


	    done
	done
    done
    wait

fi
exit
if [ $stage -le 2 ];then

    for((i=0;i<$num_dbs;i++))
    do
	db=jsalt19_spkdet_${name_vec[$i]}

        for plda in plda_${spkdet_diar_name} plda_adapt_${spkdet_diar_name} plda_adapt_snorm_${spkdet_diar_name}
	do
	    for dur in 5 15 30
	    do
		(
		    local/calibrate_${name_vec[$i]}_spkdet_v1.sh --cmd "$train_cmd" $dur $score_dir/$plda
		    $scorer data/${db}_test/trials dev $dur $score_dir/${plda}_cal_v1
		    $scorer data/${db}_test/trials eval $dur $score_dir/${plda}_cal_v1
		) &
	    done
	done
    done
    wait

fi
