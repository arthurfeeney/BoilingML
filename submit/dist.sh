#!/bin/bash
#SBATCH -A amowli_lab_gpu
#SBATCH -p gpu
#SBATCH --nodes=1
#SBATCH --gres=gpu:A30:4
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=20
#SBATCH --mem-per-cpu=6G
#SBATCH --time=24:00:00

# One node needs to be used as the "host" for the rendezvuoz
# system used by torch. This just gets a list of the hostnames
# used by the job, and selects the first one.
HOST_NODE_ADDR=$(scontrol show hostnames | head -n 1)
NNODES=$(scontrol show hostnames | wc -l)

module load anaconda/2022.05
. ~/.mycondaconf
conda activate bubble-sciml

export TORCH_DISTRIBUTED_DEBUG=DETAIL

srun torchrun \
    --nnodes $NNODES \
    --nproc_per_node 4 \
    --max_restarts 0 \
    --rdzv_backend c10d \
    --rdzv_id $SLURM_JOB_ID \
    --rdzv_endpoint $HOST_NODE_ADDR \
    --redirects 3 \
    --tee 3 \
    src/train.py \
	data_base_dir=/share/crsp/lab/ai4ts/share/simul_ts_0.1/ \
	log_dir=/share/crsp/lab/ai4ts/afeeney/log_dir \
	dataset=PB_SubCooled_0.1 \
	experiment.distributed=True \
	experiment=vel_ffno \
	experiment.train.max_epochs=10 \
	#model_checkpoint=/share/crsp/lab/ai4ts/afeeney/log_dir/23125048/subcooled/Unet_vel_dataset_2_1691692915.pt
	#experiment.train.batch_size=2 \
	#model_checkpoint=/share/crsp/lab/ai4ts/afeeney/log_dir/23103629/subcooled/DistributedDataParallel_temp_input_dataset_1_1691219910.pt
	#experiment.lr_scheduler.patience=50
	#model_checkpoint=/share/crsp/lab/ai4ts/afeeney/log_dir/23089030/subcooled/UNet2d_vel_dataset_100_1691046606.pt \
