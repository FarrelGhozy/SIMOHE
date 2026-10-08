#include <WiFi.h> // Atau sesuaikan library WiFi bawaan board Arduino Mega IoT lu

// Konfigurasi WiFi (Opsional jika mau dipantau online)
const char* ssid     = "NAMA_WIFI_LU";
const char* password = "PASSWORD_WIFI_LU";

// Definisi Pin Sensor Ultrasonik dan Relay
const int trigPin = 9;
const int echoPin = 8;
const int relayValvePin = 7; // Pin yang mengontrol Relay ke Selenoid Valve

// Batas ketinggian air (dalam sentimeter dari sensor ke permukaan air)
// Semakin kecil jaraknya, berarti air semakin penuh/banyak.
const int batasAirPenuh = 10; // Contoh: jika jarak air <= 10 cm, kran buka otomatis

void setup() {
  Serial.begin(9600);
  
  // Inisialisasi Pin
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);
  pinMode(relayValvePin, OUTPUT);
  
  // Kondisi awal valve tertutup (LOW)
  digitalWrite(relayValvePin, LOW);

  // Koneksi WiFi untuk jarak jauh (jika menggunakan board built-in WiFi)
  WiFi.begin(ssid, password);
  Serial.print("Menghubungkan ke WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nWiFi Terhubung!");
  
}

void loop() {
  // 1. Membaca jarak permukaan air dengan sensor JSN-SR04T
  long duration;
  float distanceCm;

  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);

  duration = pulseIn(echoPin, HIGH);
  distanceCm = duration * SOUND_SPEED / 2; // atau duration * 0.034 / 2

  Serial.print("Jarak Permukaan Air: ");
  Serial.print(distanceCm);
  Serial.println(" cm");

  // 2. Logika Otomatisasi Kran (Jika air banyak/penuh, kran buka otomatis)
  if (distanceCm > 0 && distanceCm <= batasAirPenuh) {
    // Kondisi Air Penuh -> Buka Kran (Selenoid Valve ON)
    digitalWrite(relayValvePin, HIGH); 
    Serial.println("STATUS: Air Penuh! Kran Otomatis TERBUKA.");
  } else {
    // Kondisi Air Aman/Kosong -> Tutup Kran (Selenoid Valve OFF)
    digitalWrite(relayValvePin, LOW);  
    Serial.println("STATUS: Air Normal. Kran Tertutup.");
  }

  // Kirim data atau jeda pembacaan tiap 2 detik
  delay(2000);
}