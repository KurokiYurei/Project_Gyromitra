using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class frameCounter : MonoBehaviour
{
    public Text fpsText;
    public float deltaTime;
    private bool showFps = false;

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.F1))
        {
            showFps = true;
            gameObject.GetComponent<Text>().enabled = true;
        }

        if (Input.GetKeyDown(KeyCode.F2))
        {
            showFps = false;
            gameObject.GetComponent<Text>().enabled = false;
        }

        if (showFps)
        {
            deltaTime += (Time.deltaTime - deltaTime) * 0.1f;
            float fps = 1.0f / deltaTime;
            fpsText.text = Mathf.Ceil(fps).ToString();
        }

    }
}
