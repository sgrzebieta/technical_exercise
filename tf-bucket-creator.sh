#!/bin/bash
PROJECT_ID="indigo-splice-422902-u1"

rand="$(echo $RANDOM)"
gsutil mb -p indigo-splice-422902-u1 -l AUSTRALIA-SOUTHEAST2 -b on "gs://tf-state-1972356"
gsutil versioning set on "gs://tf-state-1972356"