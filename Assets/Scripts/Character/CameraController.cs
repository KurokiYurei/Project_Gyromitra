using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class CameraController : MonoBehaviour
{
    // inputs

    private PlayerInput playerInput;
    private InputAction moveCamera;

    [Header("Camera")]
    public float m_AimPitch = 0.0f;
    public float m_AimYaw = 0.0f;

    public float m_MinDistance = 2.0f;
    public float m_MaxDistance = 5.0f;

    public float m_YawRotationalSpeed = 360.0f;
    public float m_PitchRotationalSped = 180.0f;

    public float m_MinPitchDistance = 85.0f;
    public float m_MaxPitchDistance = 85.0f;

    public float m_MinAimPitchDistance = -30f;
    public float m_MaxAimPitchDistance = 30f;

    private Vector3 m_currentRotation;

    private float m_Pitch = 0.0f;

    public LayerMask m_CollisionLayerMask;

    [Range(0.0f, 1.0f)]
    public float m_CameraSensivity = 0.5f;

    // shoulder aim

    [SerializeField]
    private Transform m_ShoulderCameraPosition;
    [SerializeField]
    private Transform m_NormalCameraPosition;
    [SerializeField]
    private bool m_isAiming;
    [SerializeField]
    private GameObject m_UI;

    public void SetIsAiming(bool l_isAiming)
    {
        m_isAiming = l_isAiming;
    }

    public bool GetIsAiming()
    {
        return m_isAiming;
    }

    void Start()
    {
        playerInput = GetComponent<PlayerInput>();
        moveCamera = playerInput.actions["Look"];
        m_isAiming = false;
    }

    void LateUpdate()
    {
        Debug.DrawRay(m_ShoulderCameraPosition.transform.position, m_ShoulderCameraPosition.transform.forward * 100f, Color.blue);

        if (m_isAiming)
        {
            AimCamera();
        }
        else
        {
            NormalCamera();
        }
    }

    /// <summary>
    /// Normal function of the camera if not aiming
    /// </summary>
    void NormalCamera() 
    {
        m_UI.GetComponent<UI_Manager>().ShowHud(false);

        transform.position = m_NormalCameraPosition.position;

        Vector2 input = moveCamera.ReadValue<Vector2>();

        float l_MouseDeltaX = input.x;
        float l_MouseDeltaY = input.y;
        
        m_AimYaw += l_MouseDeltaX;
        m_Pitch -= l_MouseDeltaY;
        m_Pitch = Mathf.Clamp(m_Pitch, m_MinPitchDistance, m_MaxPitchDistance);

        m_currentRotation = Vector3.Lerp(m_currentRotation, new Vector3(m_Pitch, m_AimYaw), 8 * Time.deltaTime);
        m_NormalCameraPosition.eulerAngles = m_currentRotation;
        transform.forward = m_NormalCameraPosition.forward;
    }

    /// <summary>
    /// Normal function of the camera when aiming
    /// </summary>
    void AimCamera()
    {
        m_UI.GetComponent<UI_Manager>().ShowHud(true);

        transform.position = m_ShoulderCameraPosition.position;

        Vector2 input = moveCamera.ReadValue<Vector2>();

        float l_MouseDeltaX = input.x;
        float l_MouseDeltaY = input.y;

        m_AimYaw += l_MouseDeltaX;
        m_AimPitch -= l_MouseDeltaY;
        m_AimPitch = Mathf.Clamp(m_AimPitch, m_MinAimPitchDistance, m_MaxAimPitchDistance);

        m_currentRotation = Vector3.Lerp(m_currentRotation, new Vector3(m_AimPitch, m_AimYaw), 8 * Time.deltaTime);
        m_ShoulderCameraPosition.eulerAngles = m_currentRotation;
        transform.forward = m_ShoulderCameraPosition.forward;
    }
}
