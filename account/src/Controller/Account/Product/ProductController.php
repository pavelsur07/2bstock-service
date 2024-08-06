<?php

namespace App\Controller\Account\Product;

use App\Entity\Product\Product;
use App\Entity\Product\ValueObject\ProductId;
use App\Infrastructure\Form\Product\ProductNewForm;
use App\Infrastructure\Repository\Product\ProductRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

#[Route(path: '/account', name: 'account.')]
class ProductController extends AbstractController
{
    #[Route(path:'/product', name: 'product.index', methods: ['GET'])]
    public function index(ProductRepository $products): Response
    {
        return $this->render('account/product/index.html.twig',
            [
                'pagination' => $products->getAll(),
            ]);
    }

    #[Route(path:'/product/new', name: 'product.new')]
    public function new(Request $request, ProductRepository $products): Response
    {

        $form = $this->createForm(ProductNewForm::class, []);
        $form->handleRequest($request);
        if ($form->isSubmitted() && $form->isValid()) {
            $data = $form->getData();

            $product = new Product(id: ProductId::generate(),name:$data['name'] );

            $products->save($product, true);
            $this->addFlash('success', 'Product created.');
            return $this->redirectToRoute('account.product.index');
        }
        return $this->render('account/product/new.html.twig',
            [
                'form'=> $form->createView(),
            ]);
    }
}