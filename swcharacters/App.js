/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 * @flow
 */

import React, {useEffect, useState, useCallback} from 'react';
import {
  SafeAreaView,
  StyleSheet,
  Alert,
  View,
  Text,
  FlatList,
  TouchableOpacity,
  Linking,
  Picker,
  ActivityIndicator,
  StatusBar,
} from 'react-native';
import API from './api';

const App: () => React$Node = () => {
  const [data, setData] = useState([]);
  const [dataType, setDataType] = useState('people');
  const [isLoadingData, setIsLoadingData] = useState(false);
  let dataMaxCount = 0;
  // eslint-disable-next-line no-unused-vars
  let flatList;

  const _loadData = useCallback(() => {
    if (isLoadingData) {
      return;
    }
    if (dataMaxCount !== 0 && Object.keys(data).length === dataMaxCount) {
      return;
    }
    setIsLoadingData(true);
    API.getAll(dataType, Math.ceil(Object.keys(data).length / 10) + 1)
      .then(response => {
        if (response.results) {
          dataMaxCount = Number(response.count);

          const newData = [...data.concat(response.results)];
          setData(newData);
          if (newData.length <= 10) {
            if (this.flatList !== undefined) {
              this.flatList.scrollToOffset(0);
            }
          }
        }
        setIsLoadingData(false);
      })
      .catch(e => {
        Alert.alert(e);
        setIsLoadingData(false);
      });
  });

  useEffect(() => {
    _loadData();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [dataType]);

  const _renderItem = (rowData, index) => {
    let rowDataComponent = [];
    Object.entries(rowData.item).forEach(([key, value]) => {
      if (typeof value === 'string') {
        rowDataComponent.push(
          <Text style={styles.characterRow}>
            <Text style={styles.characterRowTitle}>
              {key.replace('_', ' ')}:
            </Text>
          </Text>,
        );
        if (value.startsWith('http://') || value.startsWith('https://')) {
          rowDataComponent.push(
            <TouchableOpacity onPress={() => Linking.openURL(value)}>
              <Text style={styles.characterRowLink}>{value}</Text>
            </TouchableOpacity>,
          );
        } else {
          rowDataComponent.push(
            <Text style={styles.characterRow}>{value}</Text>,
          );
        }
      } else if (Array.isArray(value) && value.length > 0) {
        rowDataComponent.push(
          <Text style={styles.characterRowTitle}>
            {key.replace('_', ' ')}:
          </Text>,
        );
        rowDataComponent.push(<View />);
        for (const item in value) {
          if (
            value[item].startsWith('http://') ||
            value[item].startsWith('https://')
          ) {
            rowDataComponent.push(
              <TouchableOpacity onPress={() => Linking.openURL(value[item])}>
                <Text style={styles.characterRowLink}>{value[item]}</Text>
              </TouchableOpacity>,
            );
          } else {
            rowDataComponent.push(
              <Text style={styles.characterRow}>{value[item]}</Text>,
            );
          }
        }
      }
    });

    return <View style={styles.characterRowContainer}>{rowDataComponent}</View>;
  };

  const pickerValueChanged = value => {
    dataMaxCount = 0;
    setData([]);
    setDataType(value);
  };

  return (
    <>
      <StatusBar barStyle="dark-content" />
      <SafeAreaView style={styles.container}>
        <View style={styles.container}>
          <FlatList
            data={data}
            ref={ref => (this.flatList = ref)}
            extraData={data}
            keyExtractor={(_item, index) => `${index}`}
            style={styles.list}
            contentInset={{top: 4, left: 0, bottom: 0, right: 0}}
            renderItem={_renderItem}
            ItemSeparatorComponent={() => (
              <View style={styles.ItemSeparatorComponent} />
            )}
            onEndReachedThreshold={1}
            onEndReached={_loadData}
            ListFooterComponent={isLoadingData ? <ActivityIndicator /> : null}
          />
          <View style={styles.separator} />
          <View
            style={styles.pickerContainer}
            pointerEvents={isLoadingData ? 'none' : 'auto'}>
            <Picker
              selectedValue={dataType}
              enabled={!isLoadingData}
              onValueChange={pickerValueChanged}>
              <Picker.Item label="People" value="people" />
              <Picker.Item label="Planets" value="planets" />
              <Picker.Item label="Films" value="films" />
              <Picker.Item label="Species" value="species" />
              <Picker.Item label="Starships" value="starships" />
            </Picker>
          </View>
        </View>
      </SafeAreaView>
    </>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'space-between',
  },
  list: {
    flex: 0.7,
  },
  ItemSeparatorComponent: {
    height: 5,
    backgroundColor: '#000000',
    marginVertical: 8,
  },
  separator: {
    height: 2,
    backgroundColor: 'gray',
  },
  characterRowContainer: {
    padding: 8,
  },
  characterRow: {
    marginBottom: 8,
  },
  characterRowLink: {
    marginBottom: 8,
    color: 'blue',
  },
  pickerContainer: {
    flex: 0.3,
  },
  characterRowTitle: {
    marginBottom: 8,
    fontWeight: '700',
    textTransform: 'capitalize',
  },
});

export default App;
