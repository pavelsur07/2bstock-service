<?php

namespace App\Entity\User\ValueObject;

use App\Common\Entity\UuidValueObject;
use Ramsey\Uuid\Uuid;

class UserId extends UuidValueObject
{
    public static function generate(): self
    {
        return new self(Uuid::uuid4()->toString());
    }
}