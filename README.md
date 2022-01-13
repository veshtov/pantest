# pantest
test for pan

## Task details
 Write a script in a language of your choice that runs through the log files on a Linux server and publishes them to an external service.
 Files format: log-<servicename>-date-hour
 
 Location: There will be multiple directories, one for each service, inside /log. Your script will need to scan the subdirectories and locate files matching the format.
 
 Output: Publish the log data to an external service that accepts either files or logs as strings. Feel free to pick as you prefer. Please write a POST curl command. Assume a random URL for your use case.
 Also, create a cron schedule to execute the script hourly between 8 am and 8 pm.

To run script, 

SSH into system (or ansible / other automation)
sudo wget https://github.com/veshtov/pantest/blob/3f9f868ea57fae822b9d36e905902fdb41d73e79/pantest.sh -P /usr/local/sbin/ | chmod u+x /usr/local/sbin/pantest.sh
sudo crontab -l > tempcrontab
sudo echo "0 8-20 * * *" sudo /usr/local/sbin/pantest.sh >/dev/null 2>&1" >> tempcrontab
sudo crontab tempcrontab
sudo rm tempcrontab


## Crontab specifics
sudo crontab -l > tempcrontab
sudo echo "0 8-20 * * *" sudo /usr/local/sbin/pantest.sh >/dev/null 2>&1" >> tempcrontab
sudo crontab tempcrontab
sudo rm tempcrontab


## Suggested logging at scale
For logging at scale I'm mostly concerned with data flow (TLS and bandwidth costs), retention costs for both compliance/security/data mining, ease of use. 
Something like DataDog can work short term but depending on the amount of data we're looking at it could get expensive pretty quick. 


What I'm thinking long term, unifying on Cloudflare's new S3 compatible storage woudl allow us to join it with MinIO for distributed block storage that will work on a majority of teh cloud providers. 
The best part is we can utilitize the same code locally at colo and warehouse DC's to build edge compute and storage that will save significantly on cloud costs. We would be able to have containers send data to 
Cloudflare which doesn't charge ingest or egress costs (at least for now) so we can send data bulk there to be divvied up. Local data at colo and Warehouse DC can stay localized as well so we can split data based on type or use case. 

I woudl use syslog-ng or rsyslog to split off container logs out to various services. Something like datadog I would slowly reduce to security and infrastructure monitoring and keep retention minimal as I would send all other log data to Cloudflare. 

Cloudflare is building out a S3 compatible storage medium, I would probably like to move onto that for bulk storage as it's not fully open or outside of beta yet we may need to discuss it with biz dev folks
to get full access. This block storage would be cheaper and more flexible than HDFS outright, something like MiniIO would allow use to use S3 compatible block storage with HDFS. MiniIO is specifically compatible with Kubernetes and integrates with VMware vSAN and Tanzu. With Tanzu and this integrated block storage we can basically attach any of this block storage across Azure, AWS, GCP  and on prem solutions at colo + warehouse locations. This way, if the data scientists help classify data by region we can dramatically reduce long term costs while having significantly cheaper edge AI/compute at the colo/warehouse DC's. 45 Drives have storage pods that dramatically increase capacity at lower cost, runs on Ubuntu or Debian and can be easily integrated into MinIO and works well with Podman, so a lot of the code intended for docker.

If we don't use hadoop for map/reduce or if they wish to use something differne then the block storage doesn't really care and we wouldn't be out all the issues with setting up HDFS and reingesting data. These would work right off the bat to ingest and shard out for an ELK stack as well. Most of the nosql type stuff will work with this as well if they're using graph. 

so we shoudl be able to distribute the load/cost down dramatically especially if we can enforce region locking as most of the product data shoudl reside in a physical location either within a warehouse or from regional partners accessing. So something like cloudflare or azure/amazon can be used to help load balance across regions specifically. 

I'm working on some diagrams in the mean time and can throw those up when they're ready. 
