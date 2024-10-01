variable "env_vars" {
  type = map(string)
  default = {
    COMPANY_NAME= "nexa in docker"
    
    DB_USER = aws_db_instance.db.username
    DB_PASSWORD=aws_db_instance.db.password
    DB_HOST=aws_db_instance.db.endpoint 
    DB_DATABASE=aws_db_instance.db.db_name

    #AWS_S3_LAMBDA_URL=XXXXXXXX
    #AWS_S3_LAMBDA_APIKEY=XXXXXXXX

    #AWS_DB_LAMBDA_URL=XXXXXXXX
    #AWS_DB_LAMBDA_APIKEY=XXXXXXXX

    #STRESS_PATH="/usr/bin/stress"
    #LOAD_BALANCER_IFRAME_URL="https://tu_url.com"
  }
}