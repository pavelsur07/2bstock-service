<?php

namespace App\Infrastructure\Repository\Product;

use App\Entity\Product\Exception\ProductException;
use App\Entity\Product\Product;
use Doctrine\ORM\EntityManagerInterface;
use Doctrine\ORM\EntityRepository;
use Webmozart\Assert\Assert;

class ProductRepository
{

    private EntityManagerInterface $em;

    /** @var EntityRepository<Product> */
    private EntityRepository $repo;

    public function __construct(EntityManagerInterface $em)
    {
        $this->em = $em;
        $this->repo = $this->em->getRepository(Product::class);
    }

    public function get(string $id): Product
    {
        Assert::uuid($id);
        $object = $this->repo->find($id);
        if ($object === null) {
            throw new ProductException('Product not found.');
        }

        return $object;
    }

    public function getAll(): array
    {
        return $this->repo->findAll();
    }

    public function save(Product $object, bool $flush): void
    {
        $this->em->persist($object);

        if ($flush) {
            $this->em->flush();
        }
    }

    public function remove(Product $object, bool $flush): void
    {
        $this->em->remove($object);

        if ($flush) {
            $this->em->flush();
        }
    }
}