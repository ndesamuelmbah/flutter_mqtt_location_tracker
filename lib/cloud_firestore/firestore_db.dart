import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_mqtt_location_tracker/utils/general_utils.dart';
import 'package:logging/logging.dart';

class FirestoreDB {
  final Logger logger = Logger('FirestoreDB');
  static Reference signaturesRef =
      FirebaseStorage.instance.ref().child('signatures');
  static Reference profilesAndIdsRef =
      FirebaseStorage.instance.ref().child('profilesAndIds');
  static Reference supportingDocumentsRef =
      FirebaseStorage.instance.ref().child('supportingDocuments');
  static CollectionReference configurationRef =
      FirebaseFirestore.instance.collection("configs");
  static CollectionReference loansRef =
      FirebaseFirestore.instance.collection("loans");
  static CollectionReference loanApplicationsRef =
      FirebaseFirestore.instance.collection("loanApplications");
  static CollectionReference njangiRef =
      FirebaseFirestore.instance.collection("njangi");
  static CollectionReference exchangeRatesRef =
      FirebaseFirestore.instance.collection("exchangeRates");
  static CollectionReference chatRooms =
      FirebaseFirestore.instance.collection("chatRooms");
  static CollectionReference customersRef =
      FirebaseFirestore.instance.collection("customers");
  static CollectionReference stores =
      FirebaseFirestore.instance.collection("customers");
  static CollectionReference ordersRef =
      FirebaseFirestore.instance.collection("orders");
  static CollectionReference logsRef =
      FirebaseFirestore.instance.collection("logs");
  static CollectionReference chatsRef =
      FirebaseFirestore.instance.collection('chats');
  static CollectionReference contactUsRef =
      FirebaseFirestore.instance.collection("contactUs");
  static CollectionReference userDevicesRef =
      FirebaseFirestore.instance.collection("userDevices");
  static CollectionReference testsRef =
      FirebaseFirestore.instance.collection("tests");
  static CollectionReference pendingAuthenticationsRef =
      FirebaseFirestore.instance.collection("pendingAuthentications");
  static CollectionReference mediaRef =
      FirebaseFirestore.instance.collection("media");
  static CollectionReference<Map<String, dynamic>> investmentIdeasRef =
      FirebaseFirestore.instance.collection("investmentIdeas");

  static DocumentReference<Map<String, dynamic>> registeredMembersPhonesRef =
      FirebaseFirestore.instance
          .collection("registeredMembersPhones")
          .doc('phoneNumbers');

  Future<void> createUser(
      Map<String, dynamic> userData, String firebaseUserId) async {
    userData.removeWhere(
        (key, value) => (value ?? '').toString().isNullOrWhiteSpace);
    customersRef
        .doc(firebaseUserId)
        .set(userData, SetOptions(merge: true))
        .catchError((e) {});
  }

  static Future<void> updateUser(
      Map<String, dynamic> userData, String firebaseUserId) async {
    userData.removeWhere(
        (key, value) => (value ?? '').toString().isNullOrWhiteSpace);
    customersRef
        .doc(firebaseUserId)
        .set(userData, SetOptions(merge: true))
        .catchError((e) {});
  }

  static Future<Map<String, dynamic>?> getEnvVars() async {
    final ref = await configurationRef.doc('envVars').get().catchError((e, s) {
      Logger('FirestoreDB').severe(e, s);
    });
    if (ref.exists) {
      return ref.data()! as Map<String, dynamic>;
    } else {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getUserInfoByFirebaseId(
      String idValue, String idFieldName) async {
    if (idFieldName == 'uid') {
      final ref = await customersRef.doc(idValue).get().catchError((e) {});
      if (ref.exists) {
        return ref.data()! as Map<String, dynamic>;
      }
    } else {
      final ref = await customersRef
          .where(idFieldName, isEqualTo: idValue)
          .get()
          .catchError((e) {});

      if (ref.docs.isNotEmpty) {
        return ref.docs[0].data()! as Map<String, dynamic>;
      }
    }
  }

  Stream<QuerySnapshot> getChatHistory(String firebaseId) {
    int startTime =
        DateTime.now().add(const Duration(days: -40)).millisecondsSinceEpoch;
    return chatRooms
        .where('lastUpdated', isGreaterThan: startTime)
        .where('firebaseId', isEqualTo: firebaseId)
        .orderBy('lastUpdated', descending: true)
        .snapshots();
  }

  Future<void> addChatRoom(
      Map<String, dynamic> chatRoomDetails, String chatRoomId) {
    return chatRooms
        .doc(chatRoomId)
        .set(chatRoomDetails, SetOptions(merge: true))
        .catchError((e) {});
  }

  Stream<QuerySnapshot<Object>> getChats(
      String chatRoomId, bool isCustomerService) {
    int startTime =
        DateTime.now().add(const Duration(days: -5)).millisecondsSinceEpoch;
    return chatRooms
        .doc(chatRoomId)
        .collection("chats")
        .where('time', isGreaterThan: startTime)
        .where('isCustomerService', isEqualTo: !isCustomerService)
        .orderBy('time', descending: true)
        .limit(1)
        .snapshots();
  }

  Future<QuerySnapshot>? getOthersLatestChats(
      String chatRoomId, bool isCustomerService, int startTime) {
    try {
      return chatRooms
          .doc(chatRoomId)
          .collection("chats")
          .where('time', isGreaterThan: startTime)
          .where('isCustomerService', isEqualTo: !isCustomerService)
          .orderBy('time', descending: true)
          .get();
    } catch (e) {
      return null;
    }
  }

  Future<bool> addStoreMessage(String message, int storeId, int customerId,
      int sentBy, String phoneNumber) async {
    try {
      int time = DateTime.now().toUtc().millisecondsSinceEpoch;
      await stores
          .doc('$storeId'.padLeft(10, '0'))
          .collection("chats")
          .doc(phoneNumber)
          .collection('messages')
          .doc(getChatMessageId(time))
          .set({
        'message': message,
        'time': time,
        'storeId': storeId,
        'sentBy': sentBy,
        'customerId': customerId,
        'isRead': false
      });
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  }

  Future<bool> addCancelledOrders(
      Map<String, dynamic> details, int orderId, String phoneNumber) async {
    try {
      int time = DateTime.now().toLocal().millisecondsSinceEpoch;
      details['time'] = time;
      await ordersRef
          .doc('$orderId'.padLeft(10, '0'))
          .collection("cancellations")
          .doc(phoneNumber)
          .set(details);
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  }

  Future<bool> addStoreContact(int storeId, bool lastUpdatedByCustomer,
      String phoneNumber, Map<String, dynamic> details) {
    try {
      details['lastUpdatedByCustomer'] = lastUpdatedByCustomer;
      stores
          .doc('$storeId'.padLeft(10, '0'))
          .collection("chats")
          .doc(phoneNumber)
          .set(details, SetOptions(merge: true));
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getStoreChatMessages(
      int storeId, int startTime, String phoneNumber) {
    return stores
        .doc('$storeId'.padLeft(10, '0'))
        .collection("chats")
        .doc(phoneNumber)
        .collection('messages')
        .where('time', isGreaterThan: startTime)
        .orderBy('time', descending: true)
        .limit(20)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getStoreChatMessagesSnapshot(
      int storeId, int startTime) {
    final storesChatsRef =
        stores.doc('$storeId'.padLeft(10, '0')).collection("chats");
    return storesChatsRef
        .where('time', isGreaterThan: startTime)
        .orderBy('time', descending: true)
        .limit(20)
        .snapshots();
  }

  Future<QuerySnapshot> getOrders(String itemId, String buyerId,
      {bool isCheckingOrder = true}) async {
    return isCheckingOrder
        ? ordersRef
            .where("orderStatus", isNotEqualTo: "Sold")
            .where("buyerId", isEqualTo: buyerId)
            .where("itemId", isEqualTo: itemId)
            .limit(1)
            .get()
        : ordersRef
            .where("orderStatus", isNotEqualTo: "Sold")
            .where("buyerId", isEqualTo: buyerId)
            .get();
  }

  Future<QuerySnapshot> getSellersOrders(String sellerId) async {
    return ordersRef
        .where("orderStatus", isNotEqualTo: "Sold")
        .where("sellerId", isEqualTo: sellerId)
        .get();
  }

  deleteOrder(String orderId, int actualSoldTime, String actualOutcome) {
    Map<String, dynamic> updates = {
      'actualSoldTime': actualSoldTime,
      "orderStatus": "Sold",
      "actualOutcome": actualOutcome
    };
    return ordersRef.doc(orderId).update(updates);
  }

  deleteMessage(String chatRoomId, String messageId) {
    return chatRooms
        .doc(chatRoomId)
        .collection('chats')
        .doc(messageId)
        .delete();
  }

  Future<void> addMessage(
      String chatRoomId, Map<String, dynamic> chatMessageData) {
    final messageId = getChatMessageId(chatMessageData['time']);
    return chatRooms
        .doc(chatRoomId)
        .collection("chats")
        .doc(messageId)
        .set(chatMessageData, SetOptions(merge: true))
        .catchError((e) {});
  }
}
