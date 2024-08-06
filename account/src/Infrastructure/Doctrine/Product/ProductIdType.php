<?php

namespace App\Infrastructure\Doctrine\Product;


use App\Common\Infrastructure\Doctrine\UuidType;
use App\Entity\Product\ValueObject\ProductId;

class ProductIdType extends UuidType
{
    public function getName(): string
    {
        return 'product_product_uuid';
    }

    protected function typeClassName(): string
    {
        return ProductId::class;
    }
}