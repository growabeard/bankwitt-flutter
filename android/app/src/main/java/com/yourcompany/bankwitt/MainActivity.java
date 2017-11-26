package com.yourcompany.bankwitt;

import android.content.ContextWrapper;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.BatteryManager;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import android.util.TypedValue;
import android.view.View;
import android.widget.TableLayout;
import android.widget.TableRow;
import android.widget.TextView;


import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugins.PluginRegistry;

import static android.content.ContentValues.TAG;
import static android.content.Intent.ACTION_SEND;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "samples.flutter.io/battery";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);

        new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
                new MethodChannel.MethodCallHandler() {
                    @Override
                    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
                        Log.d("senddenominations", "method: " + call.method + " args: " + call.arguments.toString());
                        if (call.method.equals("getBatteryLevel")) {
                            final String jsonRepresentation = (String) call.arguments;

                            try {
                                Bitmap statementView = parseJson(jsonRepresentation);
                                //saveStatement(statementView);
                                share(statementView);
                                result.success(1);
                            }catch (JSONException jse) {
                                result.error("JSON FAILED", jse.getMessage(), -1);
                            }
                        } else {
                            result.notImplemented();
                        }

                    }
                }
        );
    }

    private void saveStatement(Bitmap statementView) {
        // save bitmap to cache directory
        try {

            File cachePath = new File(getApplicationContext().getCacheDir(), "images");
            cachePath.mkdirs(); // don't forget to make the directory
            FileOutputStream stream = new FileOutputStream(cachePath + "/image.bmp"); // overwrites this image every time
            statementView.compress(Bitmap.CompressFormat.PNG, 100, stream);
            stream.close();

        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private Bitmap parseJson(String jsonRepresentation) throws JSONException {
        JSONObject parentObject = new JSONObject(jsonRepresentation);
        Log.d("parseJson", "pre: " + parentObject.toString());
        String total = (String) parentObject.get("total");
        JSONObject user = parentObject.getJSONObject("user");
        JSONArray denominations = parentObject.getJSONArray("denominations");

        View statementView = createLayout(total, user, denominations);
        return getViewBitmap(statementView);
    }

    private Bitmap getViewBitmap(View v) {
            v.setDrawingCacheEnabled(true);

            v.measure(View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED),
                    View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED));
            v.layout(0, 0, v.getMeasuredWidth(), v.getMeasuredHeight());

            v.buildDrawingCache(true);
            Bitmap b = Bitmap.createBitmap(v.getDrawingCache());
            v.setDrawingCacheEnabled(false); // clear drawing cache

            return b;

    }

    private View createLayout(String total, JSONObject user, JSONArray denominations) throws JSONException {
        TableLayout statementView = new TableLayout(getApplicationContext());

        TableRow row;
        TextView t1, t2, valueCol, countCol, totalCol, nameCol;
        //Converting to dip unit
        int dip = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP,
                (float) 1, getResources().getDisplayMetrics());

        row = new TableRow(this);
        t1 = new TextView(this);
        t2 = new TextView(this);
        t1.setText("BANKWITT STATEMENT");
        row.addView(t1);
        statementView.addView(row, new TableLayout.LayoutParams(
                TableLayout.LayoutParams.WRAP_CONTENT, TableLayout.LayoutParams.WRAP_CONTENT));

        row = new TableRow(this);
        row.setPadding(0,0,0, 10);
        t2.setText(user.getString("first") + " " + user.getString("last"));
        row.addView(t2);
        statementView.addView(row, new TableLayout.LayoutParams(
                TableLayout.LayoutParams.WRAP_CONTENT, TableLayout.LayoutParams.WRAP_CONTENT));

        row = new TableRow(this);
        row.setPadding(0,0,0,5);
        valueCol = new TextView(this);
        countCol = new TextView(this);
        totalCol = new TextView(this);
        nameCol = new TextView(this);
        valueCol.setText("Value");
        countCol.setText("Count");
        nameCol.setText("Name");
        totalCol.setText("Total");
        row.addView(valueCol);
        row.addView(nameCol);
        row.addView(countCol);
        row.addView(totalCol);
        statementView.addView(row, new TableLayout.LayoutParams(
                TableLayout.LayoutParams.WRAP_CONTENT, TableLayout.LayoutParams.WRAP_CONTENT));


        for (int current = 0; current < denominations.length(); current++) {
            JSONObject denomination = denominations.getJSONObject(current);
            row = new TableRow(this);


            valueCol = new TextView(this);
            countCol = new TextView(this);
            totalCol = new TextView(this);
            nameCol = new TextView(this);

            valueCol.setText(denomination.getString("label"));
            valueCol.setPadding(5, 0, 5, 0);
            countCol.setText(Integer.toString(denomination.getInt("count")));
            countCol.setPadding(5, 0, 5, 0);
            nameCol.setText(denomination.getString("name"));
            nameCol.setPadding(5, 0, 5, 0);
            totalCol.setText(denomination.getString("total"));
            totalCol.setPadding(5, 0, 5, 0);

            row.addView(valueCol);
            row.addView(nameCol);
            row.addView(countCol);
            row.addView(totalCol);

            statementView.addView(row, new TableLayout.LayoutParams(
                    TableLayout.LayoutParams.WRAP_CONTENT, TableLayout.LayoutParams.WRAP_CONTENT));
        }
        statementView.setBackgroundColor(Color.WHITE);

        row = new TableRow(this);

        t1 = new TextView(this);
        t2 = new TextView(this);
        t1.setText("TOTAL: " + total);
        row.addView(t1);
        row.setPadding(0,5, 0,0);
        statementView.addView(row, new TableLayout.LayoutParams(
                TableLayout.LayoutParams.WRAP_CONTENT, TableLayout.LayoutParams.WRAP_CONTENT));

        row = new TableRow(this);
        t2.setText("Thank you for using BankWitt®©™!");
        row.setPadding(0,5,0,5);
        row.addView(t2);
        statementView.addView(row, new TableLayout.LayoutParams(
                TableLayout.LayoutParams.WRAP_CONTENT, TableLayout.LayoutParams.WRAP_CONTENT));

        return statementView;
    }

    private void share(Bitmap bitmap) {
        try {
            File file = new File(getExternalCacheDir(),"statement.png");
            FileOutputStream fOut = new FileOutputStream(file);
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, fOut);
            fOut.flush();
            fOut.close();
            file.setReadable(true, false);
            final Intent intent = new Intent(android.content.Intent.ACTION_SEND);
            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            intent.putExtra(Intent.EXTRA_STREAM, Uri.fromFile(file));
            intent.setType("image/png");
            startActivity(Intent.createChooser(intent, "Share image via"));
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

}
