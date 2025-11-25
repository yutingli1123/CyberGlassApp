// Bluetooth Low Energy constants for CyberGlass image transfer

class BleConstants {
  // Prevent instantiation
  BleConstants._();

  // BLE Services
  static const String imageServiceUuid = '503848c4-bce3-11f0-9ccd-bf30decea150'; // Control service
  static const String imageDataService1Uuid = '55a9c06c-bce3-11f0-a025-7fecb01921e9'; // Data service 1 (4 channels)
  static const String imageDataService2Uuid = '5a7c0b7c-bce3-11f0-b0e7-67cbb27841b4'; // Data service 2 (4 channels)

  // BLE Characteristics - Control
  static const String charImageRequestUuid = '5e3a50ac-bce3-11f0-b255-ef540899ea64'; // WRITE - Request capture
  static const String charImageInfoUuid = '62fccb60-bce3-11f0-9a02-c38e72d2d0c8'; // READ/NOTIFY - Image metadata
  static const String charImageControlUuid = '82832b8c-bce3-11f0-bb48-cf7a2d9f36a2'; // WRITE - Control transfer

  // BLE Characteristics - Data channels (8 parallel channels)
  static const String charImageData1Uuid = '66f0e594-bce3-11f0-ac75-8b26179f0c8c'; // Channel 1
  static const String charImageData2Uuid = '6accca16-bce3-11f0-aa05-17a54e5b82d7'; // Channel 2
  static const String charImageData3Uuid = '6e12bdca-bce3-11f0-a24e-17df33e71289'; // Channel 3
  static const String charImageData4Uuid = '716cb4e4-bce3-11f0-9bbc-838987d75d6a'; // Channel 4
  static const String charImageData5Uuid = '74974f6c-bce3-11f0-8f1d-0f29ee6587b5'; // Channel 5
  static const String charImageData6Uuid = '77c6710e-bce3-11f0-a955-638046cc804c'; // Channel 6
  static const String charImageData7Uuid = '7b53517a-bce3-11f0-8118-7f24f2ff5f0f'; // Channel 7
  static const String charImageData8Uuid = '7ee172c2-bce3-11f0-8828-574c4e3b235d'; // Channel 8

  // Connection settings
  static const int scanTimeoutSeconds = 10;
  static const int connectionTimeoutSeconds = 10;
}