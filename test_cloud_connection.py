#!/usr/bin/env python3
"""
Скрипт для тестирования подключения к облачному сервису QuestCity
"""

import requests
import socket
import dns.resolver
import sys
from datetime import datetime

def test_dns_resolution(domain):
    """Проверка DNS резолюции домена"""
    print(f"🔍 Проверка DNS для {domain}...")
    try:
        answers = dns.resolver.resolve(domain, 'A')
        ips = [str(rdata) for rdata in answers]
        print(f"✅ DNS резолюция успешна: {ips}")
        return ips
    except Exception as e:
        print(f"❌ Ошибка DNS резолюции: {e}")
        return []

def test_http_connection(url, description=""):
    """Проверка HTTP подключения"""
    print(f"🌐 Проверка HTTP подключения к {url} {description}...")
    try:
        response = requests.get(url, timeout=10, allow_redirects=False)
        print(f"✅ HTTP статус: {response.status_code}")
        if response.status_code == 301 or response.status_code == 302:
            print(f"   🔄 Редирект на: {response.headers.get('Location', 'Неизвестно')}")
        return response
    except requests.exceptions.RequestException as e:
        print(f"❌ Ошибка HTTP подключения: {e}")
        return None

def test_api_endpoint(base_url, endpoint="/api/v1/health/"):
    """Проверка API endpoint"""
    url = base_url.rstrip('/') + endpoint
    print(f"🔌 Проверка API endpoint: {url}")
    try:
        response = requests.get(url, timeout=10)
        print(f"✅ API статус: {response.status_code}")
        if response.status_code == 200:
            try:
                data = response.json()
                print(f"   📊 Ответ API: {data}")
            except:
                print(f"   📄 Ответ: {response.text[:200]}...")
        return response
    except requests.exceptions.RequestException as e:
        print(f"❌ Ошибка API: {e}")
        return None

def test_ssl_certificate(domain):
    """Проверка SSL сертификата"""
    print(f"🔒 Проверка SSL сертификата для {domain}...")
    try:
        response = requests.get(f"https://{domain}", timeout=10, verify=True)
        print(f"✅ SSL сертификат валиден")
        return True
    except requests.exceptions.SSLError as e:
        print(f"❌ Ошибка SSL сертификата: {e}")
        return False
    except requests.exceptions.RequestException as e:
        print(f"❌ Ошибка HTTPS подключения: {e}")
        return False

def main():
    print("🚀 QuestCity Cloud Connection Test")
    print("=" * 50)
    print(f"📅 Время теста: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print()

    # Конфигурация
    domain = "questcity.ru"
    server_ip = "176.98.177.16"
    
    # Тест 1: DNS резолюция
    ips = test_dns_resolution(domain)
    print()
    
    # Тест 2: HTTP подключение к домену
    http_response = test_http_connection(f"http://{domain}", "(домен)")
    print()
    
    # Тест 3: HTTP подключение к IP
    ip_response = test_http_connection(f"http://{server_ip}", "(IP адрес)")
    print()
    
    # Тест 4: API через IP
    api_response = test_api_endpoint(f"http://{server_ip}")
    print()
    
    # Тест 5: SSL сертификат
    ssl_ok = test_ssl_certificate(domain)
    print()
    
    # Тест 6: API через HTTPS (если SSL работает)
    if ssl_ok:
        https_api_response = test_api_endpoint(f"https://{domain}")
        print()
    
    # Итоговая оценка
    print("📊 ИТОГОВАЯ ОЦЕНКА")
    print("=" * 50)
    
    if ips and server_ip in ips:
        print("✅ DNS настроен правильно")
    else:
        print("❌ Проблемы с DNS")
    
    if ip_response and ip_response.status_code in [200, 405]:
        print("✅ Сервер отвечает через IP")
    else:
        print("❌ Сервер не отвечает через IP")
    
    if api_response and api_response.status_code == 200:
        print("✅ API работает через IP")
    else:
        print("❌ API не работает через IP")
    
    if http_response and http_response.status_code == 301:
        print("⚠️  Домен перенаправляет на HTTPS")
    elif http_response and http_response.status_code == 200:
        print("✅ Домен работает по HTTP")
    else:
        print("❌ Проблемы с доступом к домену")
    
    if ssl_ok:
        print("✅ SSL сертификат настроен")
    else:
        print("❌ SSL сертификат не настроен")
    
    print()
    print("🔧 РЕКОМЕНДАЦИИ:")
    if not ssl_ok:
        print("   1. Настройте SSL сертификат (Let's Encrypt)")
        print("   2. Обновите конфигурацию nginx для HTTPS")
    if http_response and http_response.status_code == 301:
        print("   3. Настройте правильный редирект с HTTP на HTTPS")
    print("   4. Проверьте настройки в панели Timeweb")

if __name__ == "__main__":
    main()

