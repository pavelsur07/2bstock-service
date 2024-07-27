<?php

namespace App\Infrastructure\Doctrine\User;


use App\Common\Infrastructure\Doctrine\UuidType;
use App\Entity\User\ValueObject\UserId;

class UserIdType extends UuidType
{
    public function getName(): string
    {
        return 'user_user_uuid';
    }

    protected function typeClassName(): string
    {
        return UserId::class;
    }
}