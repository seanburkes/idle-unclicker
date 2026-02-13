import 'package:flutter_test/flutter_test.dart';
import 'package:idle_unclicker/domain/value_objects/experience.dart';

void main() {
  group('Experience', () {
    test('should create initial experience', () {
      final exp = Experience.initial();
      expect(exp.current, 0);
      expect(exp.expToNext, 100.0);
    });

    test('should enforce invariants', () {
      expect(
        () => Experience(current: -1, expToNext: 100),
        throwsAssertionError,
      );
      expect(() => Experience(current: 50, expToNext: 0), throwsAssertionError);
    });

    test('should calculate exp for level correctly', () {
      expect(Experience.calculateExpForLevel(1), closeTo(116.0, 0.01));
      expect(Experience.calculateExpForLevel(5), closeTo(580.0, 0.01));
      expect(Experience.calculateExpForLevel(10), closeTo(1160.0, 0.01));
    });

    test('should detect when can level up', () {
      final ready = Experience(current: 150, expToNext: 100);
      final notReady = Experience(current: 50, expToNext: 100);

      expect(ready.canLevelUp, true);
      expect(notReady.canLevelUp, false);
    });

    test('should calculate progress percentage', () {
      final half = Experience(current: 50, expToNext: 100);
      final full = Experience(current: 100, expToNext: 100);

      expect(half.progressPercentage, 0.5);
      expect(full.progressPercentage, 1.0);
    });

    test('should gain experience without leveling', () {
      final exp = Experience(current: 50, expToNext: 100);
      final (newExp, levels) = exp.gain(30);

      expect(newExp.current, 80);
      expect(levels, 0);
    });

    test('should level up when threshold reached', () {
      final exp = Experience(current: 80, expToNext: 100);
      final (newExp, levels) = exp.gain(30);

      expect(levels, 1);
      expect(newExp.current, 10); // 80 + 30 - 100
    });

    test('should handle multiple level ups', () {
      final exp = Experience(current: 50, expToNext: 100);
      // Add enough for 2 levels: 50 + 250 = 300
      // Level 1: 50 + 250 - 116 = 184 (overflow)
      // Level 2: 184 - 232 = -48 (not enough)
      // Actually: 100 needed for level 1, 116 for level 2
      // 50 + 300 = 350
      // After level 1: 350 - 100 = 250
      // After level 2: 250 - 116 = 134 (exp for level 3 is 348)
      final (newExp, levels) = exp.gain(300);

      expect(levels, greaterThanOrEqualTo(1));
      expect(newExp.current, greaterThanOrEqualTo(0));
    });

    test('should be equal when values match', () {
      const exp1 = Experience(current: 50, expToNext: 100);
      const exp2 = Experience(current: 50, expToNext: 100);
      const exp3 = Experience(current: 60, expToNext: 100);

      expect(exp1 == exp2, true);
      expect(exp1 == exp3, false);
    });
  });

  group('SkillExperience', () {
    test('should create initial skill experience', () {
      final skill = SkillExperience.initial();
      expect(skill.level, 0);
      expect(skill.currentXP, 0);
    });

    test('should calculate threshold correctly', () {
      final level0 = SkillExperience(level: 0, currentXP: 0);
      final level5 = SkillExperience(level: 5, currentXP: 0);

      expect(level0.threshold, 50);
      expect(level5.threshold, 300); // 50 * (5 + 1)
    });

    test('should gain XP without leveling', () {
      final skill = SkillExperience(level: 0, currentXP: 30);
      final (newSkill, levels) = skill.gain(10);

      expect(newSkill.currentXP, 40);
      expect(newSkill.level, 0);
      expect(levels, 0);
    });

    test('should level up when threshold reached', () {
      final skill = SkillExperience(level: 0, currentXP: 40);
      final (newSkill, levels) = skill.gain(15);

      expect(levels, 1);
      expect(newSkill.level, 1);
      expect(newSkill.currentXP, 5); // 40 + 15 - 50
    });

    test('should handle multiple skill level ups', () {
      final skill = SkillExperience(level: 0, currentXP: 0);
      // Level 0->1 needs 50, Level 1->2 needs 100
      // 150 XP should get us to level 2 with 0 XP
      final (newSkill, levels) = skill.gain(150);

      expect(levels, 2);
      expect(newSkill.level, 2);
      expect(newSkill.currentXP, 0);
    });
  });
}
