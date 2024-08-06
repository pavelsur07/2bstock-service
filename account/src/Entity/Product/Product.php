<?php

namespace App\Entity\Product;

use App\Entity\Product\ValueObject\ProductId;
use Doctrine\ORM\Mapping as ORM;


#[ORM\Entity]
#[ORM\Table(name: '`product_product`')]
class Product
{
    #[ORM\Id]
    #[ORM\Column(type: 'product_product_uuid', unique: true)]
    private ProductId $id;

    #[ORM\Column(type: 'string')]
    private string $name;

    /**
     * @param ProductId $id
     * @param string    $name
     */
    public function __construct(ProductId $id, string $name)
    {
        $this->id = $id;
        $this->name = $name;
    }

    public function getName(): string
    {
        return $this->name;
    }

    public function getId(): ProductId
    {
        return $this->id;
    }

    public function changeName(string $name): void
    {
        $this->name = $name;
    }
}