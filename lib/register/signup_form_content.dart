// import 'package:flutter/material.dart';
//
// class SignUpFormContent extends StatelessWidget {
//   final TextEditingController emailController;
//   final TextEditingController passwordController;
//   final TextEditingController companyController;
//   final TextEditingController phoneController;
//   final TextEditingController innController;
//   final TextEditingController restaurantController;
//   final TextEditingController fullNameController;
//   final TextEditingController positionController;
//   final bool checkBoxValue1;
//   final bool checkBoxValue2;
//   final bool checkBoxValue3;
//   final String? emailError;
//   final String? passwordError;
//   final Function(BuildContext) registerUser;
//
//   SignUpFormContent({
//     required this.emailController,
//     required this.passwordController,
//     required this.companyController,
//     required this.phoneController,
//     required this.innController,
//     required this.restaurantController,
//     required this.fullNameController,
//     required this.positionController,
//     required this.checkBoxValue1,
//     required this.checkBoxValue2,
//     required this.checkBoxValue3,
//     required this.emailError,
//     required this.passwordError,
//     required this.registerUser,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         TextField(
//           controller: emailController,
//           decoration: InputDecoration(
//             labelText: 'Email',
//             border: OutlineInputBorder(),
//             errorText: emailError,
//           ),
//           onChanged: (value) {
//             // Очистка ошибки при изменении текста
//             registerUser(context);
//           },
//         ),
//         SizedBox(height: 16.0),
//         TextField(
//           controller: passwordController,
//           decoration: InputDecoration(
//             labelText: 'Пароль',
//             border: OutlineInputBorder(),
//             errorText: passwordError,
//           ),
//           obscureText: true,
//           onChanged: (value) {
//             // Очистка ошибки при изменении текста
//             registerUser(context);
//           },
//         ),
//         SizedBox(height: 16.0),
//         if (checkBoxValue1) ...[
//           TextField(
//             controller: restaurantController,
//             decoration: InputDecoration(
//               labelText: 'Ресторан',
//               border: OutlineInputBorder(),
//             ),
//           ),
//           SizedBox(height: 16.0),
//           TextField(
//             controller: fullNameController,
//             decoration: InputDecoration(
//               labelText: 'ФИО',
//               border: OutlineInputBorder(),
//             ),
//           ),
//           SizedBox(height: 16.0),
//           TextField(
//             controller: positionController,
//             decoration: InputDecoration(
//               labelText: 'Должность',
//               border: OutlineInputBorder(),
//             ),
//           ),
//           SizedBox(height: 16.0),
//         ],
//         if (checkBoxValue3) ...[
//           SizedBox(height: 16.0),
//           TextField(
//             controller: fullNameController,
//             decoration: InputDecoration(
//               labelText: 'ФИО',
//               border: OutlineInputBorder(),
//             ),
//           ),
//           SizedBox(height: 16.0),
//           TextField(
//             controller: positionController,
//             decoration: InputDecoration(
//               labelText: 'Должность',
//               border: OutlineInputBorder(),
//             ),
//           ),
//           SizedBox(height: 16.0),
//         ],
//         if (checkBoxValue2) ...[
//           TextField(
//             controller: companyController,
//             decoration: InputDecoration(
//               labelText: 'Название компании',
//               border: OutlineInputBorder(),
//             ),
//           ),
//           SizedBox(height: 16.0),
//           TextField(
//             controller: phoneController,
//             decoration: InputDecoration(
//               labelText: 'Номер телефона',
//               border: OutlineInputBorder(),
//             ),
//           ),
//           SizedBox(height: 16.0),
//           TextField(
//             controller: innController,
//             decoration: InputDecoration(
//               labelText: 'ИНН',
//               border: OutlineInputBorder(),
//             ),
//           ),
//           SizedBox(height: 16.0),
//         ],
//         Column(
//           children: [
//             Row(
//               children: [
//                 Checkbox(
//                   value: checkBoxValue1,
//                   onChanged: (bool? value) {
//                     // Обновление состояния чекбоксов
//                     registerUser(context);
//                   },
//                 ),
//                 Text('Вы Ресторан'),
//               ],
//             ),
//             SizedBox(width: 15.0),
//             Row(
//               children: [
//                 Checkbox(
//                   value: checkBoxValue3,
//                   onChanged: (bool? value) {
//                     // Обновление состояния чекбоксов
//                     registerUser(context);
//                   },
//                 ),
//                 Text('Для Сотрудников'),
//               ],
//             ),
//             Row(
//               children: [
//                 Checkbox(
//                   value: checkBoxValue2,
//                   onChanged: (bool? value) {
//                     // Обновление состояния чекбоксов
//                     registerUser(context);
//                   },
//                 ),
//                 Text('Для Компаний'),
//               ],
//             ),
//           ],
//         ),
//         ElevatedButton(
//           onPressed: () {
//             registerUser(context);
//           },
//           child: Text('Зарегистрироваться'),
//         ),
//       ],
//     );
//   }
// }
