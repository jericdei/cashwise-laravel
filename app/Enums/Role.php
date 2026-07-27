<?php

namespace App\Enums;

use App\Concerns\ArrayableEnum;

enum Role: string
{
    use ArrayableEnum;

    case ADMIN = 'admin';
    case EMPLOYEE = 'employee';
    case EMPLOYER = 'employer';
}
