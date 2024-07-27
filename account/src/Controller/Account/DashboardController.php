<?php

namespace App\Controller\Account;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

class DashboardController extends AbstractController
{
    #[Route(path: '/account/dashboard', name: 'account.dashboard')]
    public function index(): Response
    {
        return $this->render('account/dashboard.html.twig');
    }
}