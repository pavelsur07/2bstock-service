<?php

namespace App\Controller\Admin;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

class DashboardController extends AbstractController
{
    #[Route(path: '/admin/dashboard', name: 'admin.dashboard')]
    public function index(): Response
    {
        return $this->render('admin/dashboard.html.twig');
    }
}