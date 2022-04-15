using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class UI_Manager : MonoBehaviour
{
    [SerializeField]
    private GameObject m_Crosshair;

    [SerializeField]
    private Transform m_arrowSpawnPoint;

    [SerializeField]
    private LineRenderer m_CircleRenderer;

    private static Vector3 m_centerOfScreen = new Vector3(0.5f, 0.5f, 0f);

    private RaycastHit m_rayCastHit;

    private float m_rayLength = 100f;

    private void Update()
    {
        Debug.DrawRay(m_arrowSpawnPoint.transform.position, m_arrowSpawnPoint.transform.forward * m_rayLength, Color.red);

        if (Physics.Raycast(m_arrowSpawnPoint.transform.position, m_arrowSpawnPoint.transform.TransformDirection(Vector3.forward), 
            out m_rayCastHit, m_rayLength) && m_rayCastHit.transform.gameObject.tag == "Enemy")
        {

            ChangeColorCrosshair(Color.red);
            print("red");

        } else
        {
            ChangeColorCrosshair(Color.white);
            print("white");
        }
    }

    public void ChangeColorCrosshair(Color color)
    {
        Image[] l_imageList = this.GetComponentsInChildren<Image>();

        for (int i = 0; i < l_imageList.Length; i++)
        {
            l_imageList[i].color = color;
        }
    }

    public void ShowHud(bool show)
    {
        // m_Crosshair.SetActive(show);
        if (show)
        {
            m_CircleRenderer.enabled = true;
        } else
        {
            m_CircleRenderer.enabled = false;
        }


    }

   public void DrawCircle(int steps, float radius)
   {

        m_CircleRenderer.positionCount = steps;

        for(int currentStep = 0; currentStep < steps; currentStep++)
        {
            float l_circumferenceProgress = (float)currentStep / steps;

            float l_currentRadient = l_circumferenceProgress * 2 * Mathf.PI;

            float l_XScale = Mathf.Cos(l_currentRadient);
            float l_YScale = Mathf.Sin(l_currentRadient);

            float x = l_XScale * radius;
            float y = l_YScale * radius;

            Vector3 l_currentPos = new Vector3(x, y, 0);

            m_CircleRenderer.SetPosition(currentStep, l_currentPos);
            m_CircleRenderer.startWidth = 1f;

            // canviar la alpha del material per q
            // m_CircleRenderer.material.SetColor("_Color", new Color(1f, 1f, 1f, 0.3f));

        }

   }
}
