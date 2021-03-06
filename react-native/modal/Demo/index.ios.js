/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 */
'use strict';

var React = require('react-native');
var {
  AppRegistry,
  StyleSheet,
  Modal,
  Text,
  View,
  SwitchIOS,
  TouchableHighlight,
} = React;

var Button = React.createClass({
  getInitialState() {
    return {
      active: false,
    };
  },

  _onHighlight() {
    this.setState({active: true});
  },

  _onUnhighlight() {
    this.setState({active: false});
  },

  render() {
    var colorStyle = {
      color: this.state.active ? '#fff' : '#000',
    };
    return (
      <TouchableHighlight
        onHideUnderlay={this._onUnhighlight}
        onPress={this.props.onPress}
        onShowUnderlay={this._onHighlight}
        style={[styles.button, this.props.style]}
        underlayColor="#a9d9d4">
          <Text style={[styles.buttonText, colorStyle]}>{this.props.children}</Text>
      </TouchableHighlight>
    );
  }
});

var Demo = React.createClass({
  getInitialState() {
    return {
      animated: true,
      modalVisible: false,
      transparent: false,
    };
  },
  _setModalVisible(visible) {
    this.setState({modalVisible: visible});
  },

  _toggleAnimated() {
    this.setState({animated: !this.state.animated});
  },

  _toggleTransparent() {
    this.setState({transparent: !this.state.transparent});
  },

  render() {
    var modalBackgroundStyle = {
      backgroundColor: this.state.transparent ? 'rgba(0, 0, 0, 0.5)' : '#f5fcff',
    };
    var innerContainerTransparentStyle = this.state.transparent
      ? {backgroundColor: '#fff', padding: 20}
      : null;

    return (
      <View>
      {/*模态化视图，展示的时候是否有动画*/}
        <View style={styles.row}>
          <Text style={styles.rowTitle}>Animated</Text>
          <SwitchIOS value={this.state.animated} onValueChange={this._toggleAnimated} />
        </View>
{/*模态化视图，是否透明*/}
        <View style={styles.row}>
          <Text style={styles.rowTitle}>Transparent</Text>
          <SwitchIOS value={this.state.transparent} onValueChange={this._toggleTransparent} />
        </View>
{/*模态化视图，是否可见*/}
        <Button onPress={this._setModalVisible.bind(this, true)}>
          Present
        </Button>
        <Modal
          animated={this.state.animated}
          transparent={this.state.transparent}
          visible={this.state.modalVisible}>
{/*模态化视图，展示的子视图*/}
          <View style={[styles.container, modalBackgroundStyle]}>
            <View style={[styles.innerContainer, innerContainerTransparentStyle]}>
            {alert(this.props.children)}
              <Text>This modal was presented {this.state.animated ? 'with' : 'without'} animation.</Text>
              <Button
                onPress={this._setModalVisible.bind(this, false)}
                style={styles.modalButton}>
                Close
              </Button>
              {this.props.children}
            </View>
            
          </View>
        </Modal>

      </View>
    );
  },
});

var styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    padding: 20,
  },
  innerContainer: {
    borderRadius: 10,
  },
  row: {
    alignItems: 'center',
    flex: 1,
    flexDirection: 'row',
    marginBottom: 20,
  },
  rowTitle: {
    flex: 1,
    fontWeight: 'bold',
  },
  button: {
    borderRadius: 5,
    flex: 1,
    height: 44,
    justifyContent: 'center',
    overflow: 'hidden',
  },
  buttonText: {
    fontSize: 18,
    margin: 5,
    textAlign: 'center',
  },
  modalButton: {
    marginTop: 10,
  },
});

AppRegistry.registerComponent('Demo', () => Demo);
