import 'package:flutter_test/flutter_test.dart';
import 'package:noteshub/features/notes/widgets/smart_formatter.dart';

void main() {
  test('smart formatter promotes pasted headings and code blocks', () {
    final formatted = normalizeSmartContent('''
TCP/IP

int main()
{
  printf("Hello");
}
''');

    expect(formatted, contains('# TCP/IP'));
    expect(formatted, contains('```c'));
    expect(formatted, contains('printf("Hello");'));
  });
}
