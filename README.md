Got it 👍 — here’s the updated README with a **Teardown Section** added so a developer can fully clean up their AWS environment when they’re done testing.

---

````markdown
# AWS Serverless Data Pipeline Project

## 📌 Overview
This project is a **serverless file upload and metadata storage pipeline** built on AWS.  
It allows users to upload files to an S3 bucket, trigger a Lambda function, and store metadata in an RDS PostgreSQL database.  

We are building this step-by-step, with Terraform managing all AWS resources.  

---

## ✅ Current Components

### 1. S3 Bucket
- Bucket name: `aws-serverless-app-tgray`
- Stores all uploaded files.
- Access managed via IAM policies (least privilege enforced).

### 2. Python Utility Scripts
Located in `scripts/`:
- `upload_file.py` → Uploads a file to S3.
  ```bash
  python scripts/upload_file.py aws-serverless-app-tgray ./path/to/localfile.txt
````

* `download_file.py` → Downloads a file from S3.

  ```bash
  python scripts/download_file.py aws-serverless-app-tgray ./path/to/localfile.txt
  ```

### 3. Terraform Infrastructure

Terraform manages AWS resources.

#### Current Terraform Resources:

* `S3 Bucket` for file storage.
* `IAM Roles/Policies` for Lambda and RDS access.
* `Lambda Function` that gets triggered on file upload to S3.
* `RDS PostgreSQL Instance` (db.t3.micro) for metadata storage.

  * Database name: `serverlessdb`
  * Username: `dbadmin`
  * Password: stored in `terraform.tfvars`

#### Terraform Notes

* Run `terraform init -upgrade` on changes.
* Run `terraform apply` to provision resources.
* Add the following to `.gitignore`:

  ```
  .venv/
  __pycache__/
  .terraform/
  terraform.tfstate
  terraform.tfstate.backup
  *.zip
  ```

### 4. RDS Schema

Schema automatically initialized via Terraform (`db-init.tf`):

```sql
CREATE TABLE IF NOT EXISTS files (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    filename TEXT NOT NULL,
    bucket TEXT NOT NULL,
    uploaded_at TIMESTAMP DEFAULT NOW()
);
```

---

## 🧪 Testing Progress

* ✅ S3 bucket created and accessible.
* ✅ Python upload/download scripts working.
* ✅ Terraform applied successfully.
* ✅ Lambda set up with S3 trigger (currently basic).
* ✅ RDS PostgreSQL created and schema initialized.
* ✅ Verified DB connection with `psql`.

---

## 🚀 Next Steps

1. Wire Lambda to insert file metadata into the RDS `files` table.
2. Expand schema if needed (users, tags, etc.).
3. Add API Gateway + authentication for controlled access.
4. Add CI/CD pipeline for automatic deployment.

---

## 🛠 Tech Stack

* **AWS**: S3, Lambda, RDS (Postgres), IAM
* **Terraform**: Infrastructure as Code
* **Python**: boto3 utilities + Lambda handler
* **PostgreSQL**: Metadata database

---

## 👨‍💻 Getting Started (Fresh Developer Setup)

### 1. Clone the Repository

```bash
git clone https://github.com/YOUR_ORG/aws-serverless-data-pipeline.git
cd aws-serverless-data-pipeline
```

### 2. Configure AWS Credentials

Make sure your AWS CLI is configured with credentials that have access to S3, Lambda, RDS, and IAM.

```bash
aws configure
```

### 3. Python Environment

Create a virtual environment and install dependencies:

```bash
python -m venv .venv
source .venv/bin/activate   # Mac/Linux
.venv\Scripts\activate      # Windows PowerShell

pip install -r requirements.txt
```

### 4. Terraform Setup

Initialize and apply the Terraform code:

```bash
cd terraform
terraform init -upgrade
terraform apply
```

Enter `yes` when prompted. This provisions the S3 bucket, Lambda, IAM roles, and RDS instance.

### 5. Database Connection

Once Terraform completes, you can connect to the RDS PostgreSQL database:

```bash
psql -h <rds-endpoint> -U dbadmin -d serverlessdb
```

Password is stored in `terraform.tfvars`.

### 6. Test File Upload/Download

Upload a file:

```bash
python scripts/upload_file.py aws-serverless-app-tgray ./home/trevor/TEST.txt
```

Download it back:

```bash
python scripts/download_file.py aws-serverless-app-tgray ./home/trevor/TEST.txt
```

---

## 🧹 Teardown (Clean Up Resources)

When you’re finished testing, clean up AWS resources to avoid ongoing charges.

1. Empty the S3 bucket:

   ```bash
   aws s3 rm s3://aws-serverless-app-tgray --recursive
   ```

2. Destroy Terraform-managed resources:

   ```bash
   cd terraform
   terraform destroy
   ```

   Enter `yes` when prompted.

3. Deactivate your Python virtual environment:

   ```bash
   deactivate
   ```

At this point, your AWS account is clean and you won’t be billed for unused resources.

---

## 📂 Project Structure

```
.
├── README.md              # Project documentation
├── requirements.txt       # Python dependencies
├── scripts/               # Python S3 utility scripts
│   ├── upload_file.py
│   └── download_file.py
├── terraform/             # Infrastructure as Code
│   ├── main.tf
│   ├── providers.tf
│   ├── s3.tf
│   ├── lambda.tf
│   ├── rds.tf
│   ├── db-init.tf
│   └── variables.tf
└── .gitignore
```

---

## 📝 Notes

* `.gitignore` is set up to exclude sensitive/state files.
* RDS credentials are stored in `terraform.tfvars` (do not commit this file).
* Lambda zip package is generated by Terraform automatically.

```


