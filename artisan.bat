@echo off
pushd "%~dp0laravel_backend"
php artisan %*
popd
