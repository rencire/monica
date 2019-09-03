CREATE DATABASE monica;
CREATE USER 'monica'@'localhost' IDENTIFIED BY 'strongpassword';
GRANT ALL ON monica.* TO 'monica'@'localhost';
FLUSH PRIVILEGES;
