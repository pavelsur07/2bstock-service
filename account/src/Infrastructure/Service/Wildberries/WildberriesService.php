<?php

namespace App\Infrastructure\Service\Wildberries;
use GuzzleHttp\Client;
use GuzzleHttp\Exception\RequestException;
class WildberriesService
{
    public function getOrders($startDate, $apiKey) {
        $client = new Client();

        // Пример URL для запроса. Его нужно заменить на реальный URL Wildberries API
        $url = 'https://api.wildberries.ru/orders';

        try {
            $response = $client->request('GET', $url, [
                'headers' => [
                    'Authorization' => 'Bearer ' . $apiKey,
                    'Accept' => 'application/json'
                ],
                'query' => [
                    'startDate' => $startDate,
                    // Дополнительные параметры запроса, если нужны
                ]
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