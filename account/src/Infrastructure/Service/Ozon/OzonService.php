<?php

namespace App\Infrastructure\Service\Ozon;

use GuzzleHttp\Client;
use GuzzleHttp\Exception\RequestException;
class OzonService
{
    private int $clientId;
    private string $apiKey;


    public function getOrders($startDate, $apiKey) {
        $client = new Client();

        // Пример URL для запроса. Его нужно заменить на реальный URL Ozon API
        $url = 'https://api-seller.ozon.ru/v1/order/list';

        try {
            $response = $client->request('POST', $url, [
                'headers' => [
                    'Client-Id' => 'your_client_id',  // Укажите свой идентификатор клиента
                    'Api-Key' => $apiKey,
                    'Content-Type' => 'application/json'
                ],
                'body' => json_encode([
                    'filter' => [
                        'since' => $startDate,
                        // 'to' => 'дата окончания', // если нужен диапазон
                    ],
                    'limit' => 100  // Максимальное количество заказов, которые можно получить за раз
                ])
            ]);

            // Проверка успешности запроса
            if ($response->getStatusCode() === 200) {
                $body = $response->getBody();
                $data = json_decode($body, true); // Преобразуем JSON в ассоциативный массив

                return $data;
            } else {
                return ['error' => 'Unexpected status code: ' . $response->getStatusCode()];
            }
        } catch (RequestException $e) {
            // Обработка исключений
            return ['error' => 'Request failed: ' . $e->getMessage()];
        }
    }
}