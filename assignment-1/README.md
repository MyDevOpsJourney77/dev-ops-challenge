Assignment 1 – CloudFront CDN Setup

Below are the steps I followed to complete Assignment 1 as requested.

Step 1 — Created two S3 buckets

I created two S3 buckets:

Bucket A – for main website content

Uploaded a file that prints:
“Hello, CDN origin is working fine”

Bucket B – for the /devops-folder/ path

Uploaded a file that prints:
“Hello, CDN 2 origin is working fine”

For both buckets:

Enabled Static Website Hosting

Made the files publicly accessible using the required S3 Bucket Policy

Step 2 — Created CloudFront Distribution

I created one CloudFront distribution (without any custom domains/CNAMEs).

During creation:

Selected Bucket A as the default origin

Selected recommended settings for caching and origin settings

Did not enable WAF or extra security features (as per requirement)

Step 3 — Added Second Origin (Bucket B)

After distribution creation, I:

Opened the distribution

Went to the Origins tab

Added a new origin pointing to Bucket B

No special settings were changed — used default recommended settings.

Step 4 — Created Behaviors

Inside the CloudFront distribution, I configured two behaviors:

Behavior #1 (for /devops-folder/*)

Path Pattern: /devops-folder/*

Origin: Bucket B

Viewer Protocol: Redirect HTTP → HTTPS

Caching: Used custom cache policy (48 hours)

Behavior #2 (Default behavior)

Path Pattern: Default (*)

Origin: Bucket A

Viewer Protocol: Redirect HTTP → HTTPS

Caching: Same 48-hour policy

I saved all settings.

Step 5 — Testing the CDN

After CloudFront finished deploying, I tested both URLs:

Test A (Root URL):
https://d2foonr7m4h05f.cloudfront.net/


Output:

Hello, CDN origin is working fine

Test B (devops-folder):
https://d2foonr7m4h05f.cloudfront.net/devops-folder/


Output:

Hello, CDN 2 origin is working fine


Both tested successfully.

What I Submit

CloudFront domain URL

Folder structure in GitHub

README with these steps

Screenshots of both working URLs
