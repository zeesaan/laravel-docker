
#!/bin/sh
docker exec propsoft-backend-app-1 composer install
docker exec propsoft-backend-app-1 php artisan optimize:clear
docker exec propsoft-backend-app-1 php artisan migrate