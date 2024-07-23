//This page shows the details of the specific event when the users clicks on the event on the home page

// import 'package:eventify/chat.dart';
import 'package:eventify/view/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EventDetailsPage extends StatelessWidget {
  final String title;
  final String description;
  final String startDate;
  final String endDate;
  final String startTime;
  final String endTime;
  final String thumbnailUrl;
  final String location;
  final String price;
  final String userId;

  const EventDetailsPage({
    super.key,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    required this.thumbnailUrl,
    required this.location,
    required this.price,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text('$title details'),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              child: Image.network(
                thumbnailUrl,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chat),
                        color: Colors.blueAccent,
                        onPressed: () {
                          context.push('/chat');
                        },
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        // onTap: () {

                        //   Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //       builder: (context) => const ChatPage(),
                        //     ),
                        //   );
                        // }
                        onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => ChatScreen(userId: userId))),
                        child: const Text(
                          'Chat with Organiser',
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Date & Time'),
                  const SizedBox(height: 8),
                  _buildDateTimeRow(Icons.calendar_today, 'From:',
                      '$startDate at $startTime'),
                  const SizedBox(height: 4),
                  _buildDateTimeRow(
                      Icons.calendar_today, 'To:', '$endDate at $endTime'),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Location'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.blueAccent),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(location,
                              style: const TextStyle(color: Colors.black87))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Price'),
                  const SizedBox(height: 8),
                  Text(
                    '\$ $price',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  //     body: SingleChildScrollView(
  //       child: Padding(
  //         padding: const EdgeInsets.all(16.0),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             SizedBox(
  //               width: double.infinity,
  //               child: Image.network(
  //                 thumbnailUrl,
  //                 fit: BoxFit.cover,
  //               ),
  //             ),
  //             // Image.network(thumbnailUrl),
  //             const SizedBox(height: 16),
  //             Text(
  //               title,
  //               style: const TextStyle(
  //                 fontSize: 24,
  //                 fontWeight: FontWeight.bold,
  //                 color: Colors.black87,
  //               ),
  //             ),
  //             const SizedBox(height: 8),
  //             Text(
  //               description,
  //               style: const TextStyle(
  //                 fontSize: 16,
  //                 color: Colors.black54,
  //               ),
  //             ),
  //             // const Text(
  //             //   'Description',
  //             //   style: TextStyle(
  //             //     fontSize: 18,
  //             //     fontWeight: FontWeight.bold,
  //             //   ),
  //             // ),
  //             // const SizedBox(height: 8),
  //             // Text(description),
  //             const SizedBox(height: 16),
  //             // const Text(
  //             //   'Date & Time',
  //             //   style: TextStyle(
  //             //     fontSize: 18,
  //             //     fontWeight: FontWeight.bold,
  //             //   ),
  //             // ),
  //             const SizedBox(height: 16),
  //             _buildSectionTitle('Date & Time'),
  //             const SizedBox(height: 8),
  //             _buildDateTimeRow(
  //                 Icons.calendar_today, 'From:', '$startDate at $startTime'),
  //             const SizedBox(height: 4),
  //             _buildDateTimeRow(
  //                 Icons.calendar_today, 'To:', '$endDate at $endTime'),
  //             const SizedBox(height: 16),
  //             _buildSectionTitle('Location'),
  //             const SizedBox(height: 8),
  //             Row(
  //               children: [
  //                 const Icon(Icons.location_on, color: Colors.blueAccent),
  //                 const SizedBox(width: 8),
  //                 Expanded(
  //                     child: Text(location,
  //                         style: const TextStyle(color: Colors.black87))),
  //               ],
  //             ),
  //             const SizedBox(height: 16),
  //             _buildSectionTitle('Price'),
  //             const SizedBox(height: 8),
  //             Text(
  //               '\$ $price',
  //               style: const TextStyle(
  //                 fontSize: 18,
  //                 fontWeight: FontWeight.bold,
  //                 color: Colors.green,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
//               Text('From: $startDate at $startTime'),
//               Text('To: $endDate at $endTime'),
//               const SizedBox(height: 16),
//               const Text(
//                 'Location',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 8),
//               Text(location),
//               const SizedBox(height: 16),
//               const Text(
//                 'Price',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 8),
//               Text('\$ $price'),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
}

Widget _buildSectionTitle(String title) {
  return Text(
    title,
    style: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
  );
}

Widget _buildDateTimeRow(IconData icon, String label, String value) {
  return Row(
    children: [
      Icon(icon, color: Colors.blueAccent),
      const SizedBox(width: 8),
      Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      const SizedBox(width: 4),
      Text(
        value,
        style: const TextStyle(color: Colors.black54),
      ),
    ],
  );
}
