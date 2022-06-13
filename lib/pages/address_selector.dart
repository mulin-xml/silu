// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:silu/global_declare.dart';
import 'package:silu/http_manager.dart';
import 'package:silu/utils.dart';

import 'package:silu/widgets/amap_view.dart';

class AddressSelector extends StatefulWidget {
  const AddressSelector({Key? key, this.onTapReturn}) : super(key: key);

  final Function(Address addr)? onTapReturn;

  @override
  State<AddressSelector> createState() => _AddressSelectorState();
}

class _AddressSelectorState extends State<AddressSelector> {
  final _addrList = <Address>[];

  @override
  void initState() {
    super.initState();
    updateState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 44,
        backgroundColor: Colors.white,
        foregroundColor: Colors.brown,
        title: const Text('位置管理'),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView.separated(
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(_addrList[index].addressName),
            trailing: IconButton(
              onPressed: () => _routeToEditAddressPage(_addrList[index]),
              icon: const Icon(Icons.edit),
            ),
            onTap: () {
              if (widget.onTapReturn != null) {
                widget.onTapReturn!(_addrList[index]);
                Navigator.of(context).pop();
              }
            },
          );
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(),
        itemCount: _addrList.length,
      ),
      bottomNavigationBar: SizedBox(
        height: 60,
        child: Container(
          padding: const EdgeInsets.fromLTRB(30, 0, 30, 20),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [Icon(Icons.add), Text('新增位置')],
            ),
            onPressed: () => _routeToEditAddressPage(null),
          ),
        ),
      ),
    );
  }

  _routeToEditAddressPage(Address? addr) async {
    bool? result = await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => EditAddressPage(addr)));
    // 增删改成功即刷新界面
    if (result ?? false) {
      updateState();
    }
  }

  updateState() async {
    _addrList.clear();
    var rsp = await SiluRequest().post('get_address_list', {'user_id': u.uid});
    if (rsp.statusCode == SiluResponse.ok) {
      List addressList = rsp.data['address_list'];
      for (var elm in addressList) {
        _addrList.add(Address.fromMap(elm));
      }
    }
    setState(() {});
  }
}

class EditAddressPage extends StatefulWidget {
  const EditAddressPage(this.addr, {Key? key}) : super(key: key);

  final Address? addr;

  @override
  State<EditAddressPage> createState() => _EditAddressPageState();
}

class _EditAddressPageState extends State<EditAddressPage> {
  final TextEditingController _nameController = TextEditingController();
  double _latitude = -1;
  double _longitude = -1;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.addr?.addressName ?? '';
    _latitude = widget.addr?.latitude ?? -1;
    _longitude = widget.addr?.longtitude ?? -1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 44,
        backgroundColor: Colors.white,
        foregroundColor: Colors.brown,
        title: const Text('编辑位置'),
        centerTitle: true,
        elevation: 0,
        actions: [widget.addr != null ? TextButton(onPressed: _deleteAddress, child: const Text('删除')) : Container()],
      ),
      body: ListView(padding: const EdgeInsets.symmetric(horizontal: 16), children: [
        // 位置名称
        TextField(
          controller: _nameController,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          maxLength: 20,
          decoration: const InputDecoration(
            filled: true,
            icon: Icon(Icons.person),
            hintText: '添加一个名字',
            labelText: '位置名称',
          ),
        ),
        const Divider(indent: 10, endIndent: 10, thickness: 0.1),
        ListTile(
          leading: const Icon(Icons.location_on),
          title: const Text('选择位置'),
          trailing: const Icon(Icons.chevron_right),
          subtitle: Text('经度 ${_latitude.isNegative ? "" : _latitude.toStringAsFixed(4)}\n纬度 ${_longitude.isNegative ? "" : _longitude.toStringAsFixed(4)}'),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => AMapView((Address addr) {
                setState(() {
                  _nameController.text = addr.addressName;
                  _latitude = addr.latitude;
                  _longitude = addr.longtitude;
                });
              }),
            ));
          },
        )
      ]),
      bottomNavigationBar: SizedBox(
        height: 60,
        child: Container(
          padding: const EdgeInsets.fromLTRB(30, 0, 30, 20),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
            child: const Text('保存位置'),
            onPressed: () async {
              if (_nameController.text.isEmpty || _latitude.isNegative || _longitude.isNegative) {
                Fluttertoast.showToast(msg: '位置和名称不能为空哦');
                return;
              }
              final data = {
                'user_id': u.uid,
                'action': widget.addr == null ? 0 : 1,
                'address_id': widget.addr?.addressId ?? -1,
                'address_name': _nameController.text,
                'latitude': _latitude,
                'longitude': _longitude,
              };
              var rsp = await SiluRequest().post('edit_address', data);
              if (rsp.statusCode == SiluResponse.ok) {
                Navigator.of(context).pop(true);
              }
            },
          ),
        ),
      ),
    );
  }

  _deleteAddress() async {
    final data = {
      'user_id': u.uid,
      'action': 2,
      'address_id': widget.addr?.addressId ?? -1,
    };
    var rsp = await SiluRequest().post('edit_address', data);
    if (rsp.statusCode == SiluResponse.ok) {
      Navigator.of(context).pop(true);
    }
  }
}
