import 'package:faker/faker.dart' show Faker;
import 'package:hashnode/core/models/story.dart';

final faker = Faker();

final stories = List.generate(
  5,
  (index) => Story(
      cuid: faker.guid.guid(),
      title: faker.lorem.sentence(),
      brief: faker.lorem.sentence(),
      dateAdded: faker.date.dateTime(),
      slug: faker.internet.httpsUrl(),
      totalReactions: faker.randomGenerator.integer(100),
      responseCount: faker.randomGenerator.integer(100),
      content: faker.lorem.sentence(),
      author: faker.person.name(),
      contentMarkdown: faker.lorem.sentence(),
      coverImage: null,
      hostname: faker.internet.domainName()),
);
