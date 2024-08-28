# install-instana

This project is a fork of play-instana by Oleg Samoylov. 
It follows the similar pattern of steps: download prerequisites, generate manifests and apply manifests.

It adds support for image mirror and makes it easy to deploy components one at a time.

## Steps 

Copy instana-env-template.env file to the parent directory as instana.env: 
`cp instana-env-template.env ../instana.env` 

Update ../instana.env file with your values. 

### Install instana plugin.
`Run: 0-wget-instana-plugin.sh` 

Plugin is installed into `gen/bin` subdirectory. 
