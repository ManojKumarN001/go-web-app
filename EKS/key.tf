resource "aws_key_pair" "EKS_Key" {
  key_name = var.ec2_ssh_keys
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCLNaIeZt4EPlAj3NvhYr6+zxWqV69YvHDcBR1WdzTtHMk2/jBSr7ukZDTnBPL/oLM11D/ofo4/TWkuw9JjUkp9Iz2LAHpb6ky7vxzrgxM2jyLcD3JNbTZ0+nAxqF3JRU5KCcgVB7Hr71y2Tb9q2OHmpx5dNsXdFPXRo1LS4Es8lqbz5JGPdAG/xLoNX3M/d2vdOc1PWxS+Tgka+4KNwHdC7TmK6D0ch+lB97/hF7I5FHODV4Kk2VwRmYo0kSb4tEmSFnsxqLc4u2BbRuLtaF268c7pCWLkR/CxrT6YpQ4/KmjgeDLEDOXyQYC00UmpeYA+3H0A1Exgb8yzirNhlAOX rsa-key-20240821"
}