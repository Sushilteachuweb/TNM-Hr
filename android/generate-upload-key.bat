@echo off
REM Generate a new upload keystore for Google Play
REM This script creates a new keystore and generates the upload certificate

echo Generating new upload keystore...

REM Create keystore directory if it doesn't exist
if not exist "%USERPROFILE%\.android" mkdir "%USERPROFILE%\.android"

REM Generate the keystore
keytool -genkeypair -v -storetype PKCS12 -keystore "%USERPROFILE%\.android\upload-keystore.jks" -alias upload -keyalg RSA -keysize 2048 -validity 10000 -storepass android -keypass android -dname "CN=Your Name, OU=Your Organization, O=Your Company, L=Your City, ST=Your State, C=Your Country Code"

echo Keystore generated successfully!
echo.
echo Now generating upload certificate PEM file...

REM Export the certificate in PEM format
keytool -export -rfc -keystore "%USERPROFILE%\.android\upload-keystore.jks" -alias upload -storepass android -file upload_certificate.pem

echo.
echo Upload certificate generated: upload_certificate.pem
echo Keystore location: %USERPROFILE%\.android\upload-keystore.jks
echo.
echo Next steps:
echo 1. Upload the 'upload_certificate.pem' file to Google Play Console
echo 2. Update your key.properties file with the new keystore details
echo 3. Keep your keystore file secure and backed up!

pause
