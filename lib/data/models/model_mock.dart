import 'package:palakat/data/models/membership.dart';
import 'package:palakat/data/models/user_app.dart';

import 'church.dart';
import 'event.dart';

class ModelMock {
  static List<Event> events = [
    Event(
      id: "1",
      title: 'Ibadah ibdaha',
      location: 'Jhon Manembo, Kolom 2',
      author: user,
      dateTime: 'Sen, 28 Januari 2022 19:00',
      reminders: [
        'On Time',
      ],
    ),
    Event(
      id: "2",
      title: 'Ibadah Keibadahan',
      location: 'Utu Sengkey, Kolom 4',
      author: user,
      dateTime: 'Sen, 28 Januari 2022 19:00',
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
      author: user,
      dateTime: 'Sen, 28 Januari 2022 19:00',
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
      name: 'GMIM Riedel',
      location: 'Wawalintouan, Tondano',
    ),
    Church(
      id: '22',
      name: 'GMIM Betlehem',
      location: 'Watudambo, Watu watu',
    ),
    Church(
      id: '40',
      name: 'GMIM Madunde',
      location: 'Sansobar, Malalayang',
    ),
    Church(
      id: '40',
      name: 'GMIM Alfa Omega Bau',
      location: 'Rinegetan, Tondano',
    ),
    Church(
      id: '40',
      name: 'GMIM Harga Mati',
      location: 'Neraka, Tondano',
    ),
  ];

  static UserApp user = UserApp(
    id: "202",
    name: 'Jhon Mokodompit',
    phone: '0812 1234 1234',
    dob: '04 September 1990',
    maritalStatus: 'Belum Menikah',
    membershipId: "",
    membership: Membership(
      id: "1000",
      column: "2",
      baptize: true,
      sidi: false,
      churchId: '',
      church: churches[0],
    ),
  );
}
