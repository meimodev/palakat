import 'package:palakat/data/models/user.dart';

import 'church.dart';
import 'event.dart';

class ModelMock {
  static List<Event> events = [
    Event(
      id: "1",
      title: 'Ibadah ibdaha',
      location: 'Jhon Manembo, Kolom 2',
      authorName: 'Jhon Manembo',
      authorPhone: '0812 1234 1234',
      dateTime: 'Senin, 28/02/2022 19:00',
      reminders: [
        'On Time',
      ],
    ),
    Event(
      id: "2",
      title: 'Ibadah Keibadahan',
      location: 'Utu Sengkey, Kolom 4',
      authorName: 'Utu Masengi',
      authorPhone: '0812 4321 4321',
      dateTime: 'Minggu, 19/02/2022 13:00',
      reminders: [
        'On Time',
        '30 Minutes Before',
        '1 Hour Before',
      ],
    ),
    Event(
      id: "3",
      title: 'Ibadah Keibadahan',
      location: 'Utu Sengkey, Kolom 4',
      authorName: 'Jhon Manembo',
      authorPhone: '0812 1234 1234',
      dateTime: 'Rabu, 02/03/2022 19:00',
      reminders: [
        'On Time',
        '30 Minutes Before',
        '1 Hour Before',
      ],
    ),
  ];

  static List<Church> churches = [
    Church(
      id: '254',
      name: 'GMIM Riedel Wawalintouan',
      location: 'Wawalintouan, Tondano',
    ),
    Church(
      id: '22',
      name: 'GMIM Betlehem Watudambo',
      location: 'Have no idea, Where the f that is',
    ),
    Church(
      id: '40',
      name: 'GMIM Madunde Malalayang',
      location: 'Sansobar, Malalayang',
    ),
    Church(
      id: '254',
      name: 'GMIM Riedel Wawalintouan',
      location: 'Wawalintouan, Tondano',
    ),
    Church(
      id: '22',
      name: 'GMIM Betlehem Watudambo',
      location: 'Have no idea, Where the f that is',
    ),
    Church(
      id: '40',
      name: 'GMIM Madunde Malalayang',
      location: 'Sansobar, Malalayang',
    ),
  ];

  static User user = User(
    dob: "12 Januari 1999",
    phone: "081212341234",
    column: "2",
    id: 99,
    name: "Jhon Manembo",
    church: churches[0],
  );
}
