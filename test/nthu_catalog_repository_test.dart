import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_life_dashboard/features/class_schedule/data/academic_database.dart';
import 'package:personal_life_dashboard/features/class_schedule/data/nthu_catalog_repository.dart';
import 'package:personal_life_dashboard/features/class_schedule/domain/nthu_academic.dart';

void main() {
  test('official current JSON keeps zero-credit courses', () {
    final bytes = utf8.encode(
      jsonEncode([
        {
          '科號': '11510PE111019',
          '課程中文名稱': '體育',
          '課程英文名稱': 'Physical Education',
          '學分數': '0',
          '授課語言': '中文',
          '授課教師': 'FAN CHIANG HAO',
          '開課單位': 'Physical Education Center',
          '教室與上課時間': '',
        },
      ]),
    );

    final courses = NthuCurrentJsonSource.parseCurrentJson(
      bytes,
      requestedTermCode: '11510',
    );

    expect(courses, hasLength(1));
    expect(courses.single.displayName, 'Physical Education');
    expect(courses.single.credits, 0);
    expect(courses.single.instructorNames, ['FAN CHIANG HAO']);
    expect(courses.single.department, 'Physical Education Center');
  });

  test(
    'catalog search can target professor and department and filter language',
    () async {
      final db = AcademicDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final repository = NthuCatalogRepository(db);
      final term = NthuTerm('11510');

      await repository.cache(
        NthuCatalogPayload(
          term: term,
          sourceType: NthuCatalogSourceType.currentJson,
          sourceUrl: 'test',
          fetchedAt: DateTime(2026, 9, 15),
          courses: const [
            NthuCatalogCourseModel(
              id: 'pe',
              termCode: '11510',
              officialCourseCode: '11510PE111019',
              chineseName: '體育',
              englishName: 'Physical Education',
              credits: 0,
              teachingLanguage: 'English',
              instructorNames: ['FAN CHIANG HAO'],
              department: 'Physical Education Center',
              subject: 'PE',
              meetings: [],
            ),
            NthuCatalogCourseModel(
              id: 'math',
              termCode: '11510',
              officialCourseCode: '11510MATH202',
              chineseName: '離散數學',
              englishName: 'Discrete Mathematics',
              credits: 3,
              teachingLanguage: 'Chinese',
              instructorNames: ['LIN TEST'],
              department: 'Department of Mathematics',
              subject: 'MATH',
              meetings: [],
            ),
          ],
        ),
      );

      final byProfessor = await repository.search(
        term.code,
        query: 'fan chiang',
        field: NthuCatalogSearchField.professor,
      );
      expect(byProfessor.map((course) => course.id).toList(), ['pe']);

      final byDepartmentText = await repository.search(
        term.code,
        query: 'physical education',
        field: NthuCatalogSearchField.department,
      );
      expect(byDepartmentText.map((course) => course.id).toList(), ['pe']);

      final byDepartmentFilter = await repository.search(
        term.code,
        department: 'Department of Mathematics',
      );
      expect(byDepartmentFilter.map((course) => course.id).toList(), ['math']);

      final byLanguage = await repository.search(
        term.code,
        language: 'English',
      );
      expect(byLanguage.map((course) => course.id).toList(), ['pe']);

      final allFields = await repository.search(term.code, query: 'physical');
      expect(allFields.map((course) => course.id).toList(), ['pe']);
    },
  );
}
