## check for DB up before starting the panel
echo "Checking database status."
until nc -z -v -w30 $DB_HOST 3306
do
  echo "Waiting for database connection..."
  # wait for 1 seconds before check again
  sleep 1
done

## make sure the db is set up
echo -e "Migrating and Seeding D.B"
php artisan migrate --seed --force

## start cronjobs for the queue
echo -e "Starting cron jobs."
crond -L /var/log/crond -l 5

echo -e "Starting supervisord."
exec "$@"