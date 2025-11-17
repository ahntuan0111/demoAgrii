<?php
return [
    'default' => env('DB_CONNECTION', 'mongodb'),
    'connections' => [
        'mongodb' => [
            'driver' => 'mongodb',
            'host' => env('MONGODB_HOST', '127.0.0.1'),
            'port' => env('MONGODB_PORT', 27017),
            'database' => env('MONGODB_DATABASE', 'vtnn_db'),
            'username' => env('MONGODB_USERNAME', ''),
            'password' => env('MONGODB_PASSWORD', ''),
            'options'  => ['appname' => 'agri-admin'],
        ],
    ],
    'migrations' => 'migrations',
];
