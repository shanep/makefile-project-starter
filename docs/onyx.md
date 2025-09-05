# Onyx Information

Information about using Onyx, the Boise State University High Performance
Computing (HPC) cluster.

## Accessing Onyx off Campus

- If you are off campus, first log in to the [VPN](https://docs.google.com/document/d/1dkMJf3NyVHfU60B-3RvWq_TBn4uyeF8g5PyjZCz2mUU/edit?usp=drive_link)
- Then you can use ssh as normal `ssh yourname@onyx.boisestate.edu`

### Troubleshooting

If you see the error `"Host key verification failed..."`, when you connect it
is normal and probably due to a hardware upgrade. You can resolve it with the
command below.

- **GENTLE OPTION:**  `ssh-keygen -R onyx.boisestate.edu`
  - This will not hurt anything; it just removes the old onyx.boisestate.edu entries. They will be regenerated the first time you connect.
- **NUKE OPTION**  `rm -f ~/.ssh/known_hosts`
  - This removes the entire file, it will be regenerated when you use ssh.

## Generating Submission Report on Onyx

1. Install [mini-conda](https://www.anaconda.com/docs/getting-started/miniconda/install#linux-2)
2. Then install gcovr: `conda install conda-forge::gcovr`
3. Generate the Report
  - Navigate to your source repo.
  - Change to the `scripts` directory.
  - Run the script: `./create-submission-report.sh`
  - Add, commit, and push the report to GitHub
