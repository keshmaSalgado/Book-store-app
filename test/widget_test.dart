import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:online_bookstore/models/book_model.dart';
import 'package:online_bookstore/models/user_model.dart';
import 'package:online_bookstore/screens/auth/login_screen.dart';
import 'package:online_bookstore/widgets/book_card.dart';
import 'package:online_bookstore/widgets/custom_button.dart';

void main() {
  test('UserModel json serialization works', () {
    final user = UserModel.fromJson({
      'id': 1,
      'name': 'Test Admin',
      'email': 'admin@bookverse.com',
      'role': 'admin',
      'status': 'active',
    });

    expect(user.isAdmin, isTrue);
    expect(user.isStaff, isFalse);
    expect(user.isCustomer, isFalse);
    expect(user.name, 'Test Admin');
  });

  test('BookModel stock and price calculations work', () {
    final book = BookModel.fromJson({
      'id': 10,
      'title': 'Flutter in Action',
      'author': 'Eric Windmill',
      'price': '36.00',
      'stock_quantity': '3',
    });

    expect(book.inStock, isTrue);
    expect(book.isLowStock, isTrue);
    expect(book.price, 36.00);
    expect(book.stockQuantity, 3);
  });

  testWidgets('CustomButton renders text and triggers callback', (WidgetTester tester) async {
    bool tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomButton(
            text: 'Sign In',
            onPressed: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Sign In'), findsOneWidget);
    await tester.tap(find.text('Sign In'));
    expect(tapped, isTrue);
  });

  testWidgets('LoginScreen displays demo credentials and input fields', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginScreen(),
      ),
    );

    expect(find.text('Welcome to BookVerse'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Admin'), findsOneWidget);
    expect(find.text('Staff'), findsOneWidget);
    expect(find.text('Customer'), findsOneWidget);
  });

  testWidgets('BookCard renders title, price and in-stock badge', (WidgetTester tester) async {
    final sampleBook = BookModel(
      id: 1,
      title: 'Clean Code',
      author: 'Robert C. Martin',
      price: 38.50,
      stockQuantity: 10,
      categoryName: 'Technology',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BookCard(
            book: sampleBook,
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('Clean Code'), findsOneWidget);
    expect(find.text('Robert C. Martin'), findsOneWidget);
    expect(find.text('\$38.50'), findsOneWidget);
    expect(find.text('In Stock'), findsOneWidget);
  });
}
