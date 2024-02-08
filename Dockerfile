# Use the official Ubuntu 20.04 image as your parent image.
FROM ubuntu:22.04

# Let the python output directly show in the terminal without buffering it first.
ENV PYTHONUNBUFFERED=1

# Update the list of packages, then install some necessary dependencies.
RUN apt-get update && apt-get install -y \
  wget \
  git \
  bzip2 \
  libglib2.0-0 \
  libxext6 \
  libsm6 \
  libxrender1 \
  make\
  g++\
  vim\
  ffmpeg\
  libsm6\ 
  libxext6\
  sudo

# Set the working directory 
WORKDIR /app

RUN rm -rf /var/lib/apt/lists/*

# Download and install the latest version of Miniconda to /opt/conda.
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
  && bash Miniconda3-latest-Linux-x86_64.sh -b -p /opt/conda \
  && rm Miniconda3-latest-Linux-x86_64.sh 

# Add Miniconda's binary directory to PATH.
ENV PATH /opt/conda/bin:$PATH

# Use conda to create a new environment named EasyEdit and install Python 3.9.7. 
RUN conda create -n EasyEdit python=3.9.7 -y
ENV PATH /opt/conda/envs/EasyEdit/bin:$PATH

# Initialize bash shell so that 'conda activate' can be used immediately.
RUN conda init bash

# Copy the (previously cloned) repo
COPY * /app

# Activate the EasyEdit conda environment and install the Python dependencies listed in requirements.txt.
RUN /bin/bash -c "source /opt/conda/etc/profile.d/conda.sh >> ~/.bashrc && conda activate EasyEdit >> ~/.bashrc && pip install notebook==5.7.8 && pip install --no-cache-dir -r requirements.txt"

# Create a new user with its home directory located at the top of the repo
# This ensures dotfiles in the top of the repo are seen by the container's shell
RUN useradd -m -d /app -G sudo easyedit
RUN echo 'easyedit ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

# Select the user for subsequent commands
USER easyedit
