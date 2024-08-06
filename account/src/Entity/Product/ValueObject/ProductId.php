<?php

namespace App\Entity\Product\ValueObject;

use App\Common\Entity\UuidValueObject;
use Ramsey\Uuid\Uuid;


class ProductId extends UuidValueObject
{
    public static function generate(): self
    {
        return new self(Uuid::uuid4()->toString());
    }
}