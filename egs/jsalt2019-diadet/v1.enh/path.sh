
export JSALT_ROOT=$(readlink -f `pwd -P`/../../..)
export TOOLS_ROOT=$JSALT_ROOT/tools

export KALDI_ROOT=$TOOLS_ROOT/kaldi/kaldi
export PATH=$PWD/utils/:$KALDI_ROOT/tools/openfst/bin:$KALDI_ROOT/tools/sph2pipe_v2.5:$PWD:$PATH
[ ! -f $KALDI_ROOT/tools/config/common_path.sh ] && echo >&2 "The standard file $KALDI_ROOT/tools/config/common_path.sh is not present -> Exit!" && exit 1
. $KALDI_ROOT/tools/config/common_path.sh
export LC_ALL=C

#sctk
PATH=$KALDI_ROOT/tools/sctk-2.4.10/src/md-eval:$PATH

#hyperion
HYP_ROOT=$TOOLS_ROOT/hyperion/hyperion

#Anaconda env
CONDA_ROOT=$TOOLS_ROOT/anaconda/anaconda3.5
if [ -f "$CONDA_ROOT/etc/profile.d/conda.sh" ]; then
    #for conda version >=4.4 do    
    . $CONDA_ROOT/etc/profile.d/conda.sh
    conda activate
else
    #for conda version <4.4 do 
    PATH=$CONDA_ROOT/bin:$PATH
fi

if [ "$(hostname --domain)" == "cm.gemini" ];then
    module load cuda10.0/toolkit
    module load ffmpeg

    #CuDNN env
    CUDNN_ROOT=$TOOLS_ROOT/cudnn/cudnn-10.0-v7.4

    #torch env
    export TORCH=pytorch1.0_cuda10.0

else
    LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH
    LD_LIBRARY_PATH=/usr/local/cuda/lib:$LD_LIBRARY_PATH
    if [ ! -d /usr/local/cuda/lib64 ]; then
	LD_LIBRARY_PATH=$HOME/usr/local/cuda/lib64:$LD_LIBRARY_PATH
    fi

    #CuDNN env
    CUDNN_ROOT=$TOOLS_ROOT/cudnn/cudnn-9.0-v7.4

    #torch env
    export TORCH=pytorch1.0_cuda9.0
fi

# export CPATH=$HOME/usr/local/cudnn-v5.1/include:/usr/local/cuda/include:$CPATH
# export LIBRARY_PATH=$HOME/usr/local/cudnn-v5.1/lib64:/usr/local/cuda/lib64:/usr/local/cuda/lib:$LIBRARY_PATH

export HDF5_USE_FILE_LOCKING=FALSE

export MPLBACKEND="agg"
export PATH=$HYP_ROOT/hyperion/bin:/usr/local/cuda/bin:$PATH
export PYTHONPATH=$HYP_ROOT:$PYTHONPATH
export LD_LIBRARY_PATH
export LC_ALL=C

wait_file() {
    local file="$1"; shift
    local wait_seconds="${2:-30}"; shift # 10 seconds as default timeout
    for((i=0; i<$wait_seconds; i++)); do
	[ -f $file ] && return 1
	sleep 1s
    done
    return 0
}

export -f wait_file
