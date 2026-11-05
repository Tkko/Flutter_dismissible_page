import 'package:dismissible_page_example/demo/models/models.dart';
import 'package:flutter/material.dart';

class DemoPhoto {
  const DemoPhoto(this.url, this.title, this.place);

  final String url;
  final String title;
  final String place;
}

final demoPhotos = <DemoPhoto>[
  DemoPhoto(DismissiblePageModel.naturePhotos[0], 'Alpine lake', 'Dolomites'),
  DemoPhoto(DismissiblePageModel.foodPhotos[0], 'Charcoal steak', 'Lisbon'),
  DemoPhoto(DismissiblePageModel.naturePhotos[1], 'Golden valley', 'Yosemite'),
  DemoPhoto(DismissiblePageModel.foodPhotos[1], 'Fresh salad', 'Tbilisi'),
  DemoPhoto(
    DismissiblePageModel.naturePhotos[2],
    'Forest path',
    'Black Forest',
  ),
  DemoPhoto(DismissiblePageModel.foodPhotos[2], 'Spiced bowl', 'Marrakesh'),
  DemoPhoto(DismissiblePageModel.naturePhotos[3], 'Misty ridge', 'Lofoten'),
  DemoPhoto(DismissiblePageModel.foodPhotos[3], 'Ramen night', 'Osaka'),
];

class DemoProduct {
  const DemoProduct(this.photo, this.name, this.price, this.blurb);

  final DemoPhoto photo;
  final String name;
  final int price;
  final String blurb;

  String get tag => 'product-${photo.url}';
}

final demoProducts = <DemoProduct>[
  DemoProduct(
    demoPhotos[0],
    'Alpine Lake',
    48,
    'Giclée print on 310 gsm cotton paper, signed and numbered.',
  ),
  DemoProduct(
    demoPhotos[2],
    'Golden Valley',
    56,
    'Warm morning light over the valley floor, shot on 35 mm film.',
  ),
  DemoProduct(
    demoPhotos[4],
    'Forest Path',
    42,
    'A quiet path through old spruce, printed with pigment inks.',
  ),
  DemoProduct(
    demoPhotos[6],
    'Misty Ridge',
    64,
    'Low cloud rolling over the ridge at first light.',
  ),
];

class DemoTrack {
  const DemoTrack(this.title, this.artist, this.top, this.bottom, this.icon);

  final String title;
  final String artist;
  final Color top;
  final Color bottom;
  final IconData icon;
}

const demoTracks = <DemoTrack>[
  DemoTrack(
    'Midnight Drive',
    'Neon Harbor',
    Color(0xff7b5cff),
    Color(0xff1b1245),
    Icons.nightlight_round,
  ),
  DemoTrack(
    'Golden Hour',
    'Sunday Atlas',
    Color(0xffff9a5c),
    Color(0xff5c1f2e),
    Icons.wb_twilight,
  ),
  DemoTrack(
    'Glass Rooms',
    'Violet Static',
    Color(0xff2ec4b6),
    Color(0xff0b2a35),
    Icons.blur_on,
  ),
  DemoTrack(
    'Paper Planes',
    'Low Tide',
    Color(0xffff5c8a),
    Color(0xff3a1030),
    Icons.flight,
  ),
  DemoTrack(
    'Slow Burn',
    'Ember & Oak',
    Color(0xffffc857),
    Color(0xff3d2108),
    Icons.local_fire_department,
  ),
];

class DemoMessage {
  const DemoMessage(this.text, {required this.mine});

  final String text;
  final bool mine;
}

class DemoContact {
  const DemoContact(
    this.name,
    this.color,
    this.preview,
    this.time,
    this.messages, {
    this.unread = 0,
  });

  final String name;
  final Color color;
  final String preview;
  final String time;
  final int unread;
  final List<DemoMessage> messages;

  String get initials => name.split(' ').map((part) => part[0]).take(2).join();
}

const demoContacts = <DemoContact>[
  DemoContact(
    'Nina Okafor',
    Color(0xff7b5cff),
    'Sent you the final mockups',
    '9:41',
    [
      DemoMessage('Hey! Are the new screens ready?', mine: false),
      DemoMessage('Almost. Polishing the dismiss animation.', mine: true),
      DemoMessage('The spring on release feels so good', mine: false),
      DemoMessage('Right? It follows your finger now.', mine: true),
      DemoMessage('Sent you the final mockups', mine: false),
    ],
    unread: 2,
  ),
  DemoContact(
    'Luka Beridze',
    Color(0xff2ec4b6),
    'Lunch at 1?',
    '9:12',
    [
      DemoMessage('Lunch at 1?', mine: false),
      DemoMessage('Perfect, same place as last time', mine: true),
    ],
  ),
  DemoContact(
    'Design Crit',
    Color(0xffff7a59),
    'Maya: pushing the review to Friday',
    'Mon',
    [
      DemoMessage('Pushing the review to Friday', mine: false),
      DemoMessage('Works for me', mine: true),
      DemoMessage('Bring the motion specs', mine: false),
    ],
    unread: 1,
  ),
  DemoContact(
    'Sophie Martin',
    Color(0xffff5c8a),
    'Thanks again for the help!',
    'Sun',
    [
      DemoMessage('Thanks again for the help!', mine: false),
      DemoMessage('Anytime', mine: true),
    ],
  ),
  DemoContact(
    'Tornike',
    Color(0xff00d573),
    'Swipe right to go back',
    'Sat',
    [
      DemoMessage('Swipe right anywhere to go back', mine: false),
      DemoMessage('Like a native iOS screen?', mine: true),
      DemoMessage('Exactly, and it works on Android too', mine: false),
    ],
  ),
];

class DemoStory {
  const DemoStory({
    required this.category,
    required this.title,
    required this.subtitle,
    required this.photo,
    required this.paragraphs,
  });

  final String category;
  final String title;
  final String subtitle;
  final DemoPhoto photo;
  final List<String> paragraphs;

  String get tag => 'story-${photo.url}';
}

final demoStories = <DemoStory>[
  DemoStory(
    category: 'TRAVEL',
    title: 'Valleys that never sleep',
    subtitle: 'Three days chasing golden hour',
    photo: demoPhotos[2],
    paragraphs: const [
      'Long before sunrise the valley floor is already awake. Photographers '
          'line the meadow, thermoses in hand, waiting for the first light to '
          'catch the granite.',
      'We spent three days moving with the sun: up before dawn, a long lunch '
          'while the light turned harsh, and back out for the hour when '
          'everything glows.',
      'The best frame of the trip was an accident, taken while packing up '
          'after the light had supposedly gone.',
    ],
  ),
  DemoStory(
    category: 'FOOD',
    title: 'Night market, slow food',
    subtitle: 'Where Osaka eats after midnight',
    photo: demoPhotos[7],
    paragraphs: const [
      'The best bowl in the city is served at 1 a.m. from a counter with six '
          'stools and a line that never gets shorter.',
      'Nobody rushes you. The broth has simmered since the morning, and the '
          'cook knows exactly how long each noodle needs.',
      'Order the house special, finish the broth, and walk home through the '
          'quiet streets.',
    ],
  ),
  DemoStory(
    category: 'WILD',
    title: 'Above the cloud line',
    subtitle: 'A winter ridge walk in Lofoten',
    photo: demoPhotos[6],
    paragraphs: const [
      'The trail starts in fog and ends in sunshine. Somewhere around the '
          'second ridge you climb out of the cloud and the whole sea of white '
          'spreads out below you.',
      'It is cold, quiet and completely worth the early alarm.',
      'Pack layers, bring more water than you think you need, and start '
          'before the wind picks up.',
    ],
  ),
];
